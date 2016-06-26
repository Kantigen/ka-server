package KA::WebSocket;

use Moose;
use MooseX::NonMoose;

extends 'Plack::Component';
use Carp;
use Plack::Response;
use AnyEvent;
use AnyEvent::WebSocket::Server;
use Try::Tiny;
use Plack::App::WebSocket::Connection;
use JSON;
use Data::Dumper;
use Log::Log4perl;

use KA::ClientCode;
use KA::WebSocket::Context;
use KA::Queue;

has ws_server => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_ws_server',
);

has room => (
    is      => 'rw',
    default => 'main',
);

has hb_timer => (
    is      => 'rw',
);

sub _build_ws_server {
    my ($self) = @_;

    return AnyEvent::WebSocket::Server->new;
}

# A hash of all clients that are connected to this server
has connections => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub log {
    my ($self) = @_;
    my $server = $self->room || "null";
    return Log::Log4perl->get_logger( "WS::".$self->room );
}

sub incr_stat {
    my ($self, $attr) = @_;

    $self->$attr($self->$attr + 1);
}

sub read_and_reset_stat {
    my ($self, $attr) = @_;

    my $val = $self->$attr;
    $self->$attr(0);
    return $val;
}

# Statistic values
# (how many new connections)
#
has [qw(stats_new_connections stats_die_connections stats_sent_messages)] => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

# Give the module a heartbeat (every 10 seconds)
#
sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD WEBSOCKET #### $self");
    my $ws = AnyEvent->timer(
        after       => 0.0,
        interval    => 10,
        cb          => sub {
            $self->heartbeat;
        },
    );
    $self->hb_timer($ws);
}

# Generate a hash for the statistics of this instance
# Note: this structure will be augmented by descendents
#
sub instance_stats {
    my ($self) = @_;

    my $stats = inner() || {};
    $stats->{time}              = time;
    $stats->{room}              = $self->room;
    $stats->{number_of_clients} = $self->number_of_clients;
    $stats->{new_connections}   = $self->read_and_reset_stat('stats_new_connections');
    $stats->{die_connections}   = $self->read_and_reset_stat('stats_die_connections');
    $stats->{sent_messages}     = $self->read_and_reset_stat('stats_sent_messages');

    return $stats;
}

# Called every heartbeat to report it's stats and health
#
sub heartbeat {
    my ($self) = @_;

    my $stats = $self->instance_stats;
    # Put the stats onto the stats queue
    my $queue = KA::Queue->instance;
    my $job = $queue->publish('stats', {
        task        => 'websocket',
        stats       => $stats,
    },{
        priority    => 1000,
    });
}


# A fatal error has occurred and the connection cannot be made
#
sub fatal {
    my ($self, $connection, $msg) = @_;

    $self->log->error($@);
}

# General purpose send method, so we can log and record stats
#
sub send {
    my ($self, $connection, $msg) = @_;

    $self->log->info("Sent: [$msg]");
    $self->incr_stat('stats_sent_messages');
    $connection->send($msg);
}

# Send a message to the one client in the 'context'
# 
sub render_json {
    my ($self, $context, $json) = @_;

    my $sent = JSON->new->encode($json);
    $self->send($context->connection, $sent);
}

# Send a message to one client, without the context
#
sub send_json {
    my ($self, $connection, $route, $json) = @_;

    my $msg = {
        room        => $self->room,
        route       => $route,
        content     => $json,
    };
    my $sent = JSON->new->encode($msg);
    $self->send($connection, $sent);
}
 
# Broadcast the same message to every connected client
# 
sub broadcast_json {
    my ($self, $route, $content) = @_;

    my $json = {
        room    => $self->room,
        route   => $route,
        content => $content,
    };
    my $log = $self->log;

    my $sent = JSON->new->encode($json);
    $log->info("BCAST: [$self] [$sent] connections=[".$self->number_of_clients."]");
    my $i = 0;
    foreach my $con_key (keys %{$self->connections}) {
        my $connection = $self->connections->{$con_key};
        $self->send($connection, $sent);
    }
}

# Return the number of clients connected to this room
#
sub number_of_clients {
    my ($self) = @_;

    return scalar(keys %{$self->connections});
}

# What we do on a client making a connection to the server
# over-ride this in each class (usually a welcome message)
# 
sub on_connect {
    my ($self, $context) = @_;

    return {};
}

# Establish a connection
# 
sub on_establish {
    my ($self, $connection, $env) = @_;

    $self->incr_stat('stats_new_connections');
    my $log = $self->log;
    $log->info("Establish: [$connection]");

    my $context = KA::WebSocket::Context->new({
        room        => $self->room,
        connection  => $connection,
        content     => {},
    });
    $log->debug("Establish");
    
    my $con_ref = $self->connections;

    $con_ref->{$connection} = $connection;
    $log->info("START: there are ".scalar(keys %{$self->connections}). " connections");
                
    my $reply = {
        room        => $self->room,
        route       => '/welcome',
        content     => $self->on_connect($context),
    };
    $log->debug("Establish");
    $self->render_json($context, $reply);

    my $state = {
    };
    $log->debug("Establish");
    
    $connection->on(
        message => sub {
            $self->_on_message($state, @_);
        }
    );
    $connection->on(
        finish => sub {
            $self->incr_stat('stats_die_connections');
            $self->kill_client_data($connection);
        },
    );
}

# On receiving a message from a client
#
sub _on_message {
    my ($self, $state, $connection, $msg) = @_;

    my $log = $self->log;

    $log->info("RCVD: $msg");

    my $json = JSON->new;
    my $json_msg = eval {$json->decode($msg)};
    if ($@) {
        $log->error($@);
        $self->fatal($connection, $@);
        return;
    }

    $log->debug("Establish");
    my $path        = $json_msg->{route};
    my $content     = $json_msg->{content} || {};
    my $msg_id      = $json_msg->{msgId};
    my $client_code  = $json_msg->{clientCode};

    eval {
        my ($route, $method) = $path =~ m{(.*)/([^/]*)};
        $method = "ws_".$method;
        $route =~ s{/$}{};
        $route =~ s{^/}{};
        $route =~ s{/}{::};
        $route =~ s/([\w']+)/\u\L$1/g;      # Capitalize user::foo to User::Foo
        $log->debug("route = [$route]");
        my $obj;
        if ($route) {
            $route = ref($self)."::".$route;
            eval "require $route";
            $obj = $route->new({});
        }
        else {
            $log->debug("ROUTE... [SELF!]");
            $route = $self;
            $obj = $self;
        }
        $log->debug("route = [$route]");
        my $context = KA::WebSocket::Context->new({
            room            => $self->room,
            connection      => $connection,
            content         => $content,
            msg_id          => $msg_id,
            client_code     => $client_code,
        });
        $log->debug("Call [$obj][$method]");

        # If the method returns content, then render
        # a JSON reply
        # 
        my $content = $obj->$method($context);
        if (defined $content) {
            my $reply = {
                room        => $self->room,
                route       => $path,
                content     => $content,
                status      => 0,
                message     => 'OK',
            };
            if ($msg_id) {
                $reply->{msgId} = $msg_id;
            }

            $self->render_json($context, $reply);
        }
    };

    my @error;
    if ($@ and ref($@) eq 'ARRAY') {
        $log->warn("ARRAY ERROR");
        @error = @{$@};
    }
    elsif ($@) {
        $log->warn("UNKNOWN ERROR [".$@."]");
        @error = (
            1000,
            'unknown error',
            'please refer to server error log!',
        );
    }
    if (@error) {
        $self->report_error($connection, \@error, $path, $msg_id);

    }
}


# Remove all data held for the client
#
sub kill_client_data {
    my ($self, $connection) = @_;

    my $log = $self->log;
    my $con_ref = $self->connections;
    delete $con_ref->{$connection};
    $log->info("FINISH: [$self] there are ".scalar(keys %{$self->connections}). " connections");
    undef $connection;
    $log->info("killed connection data");
}


# Report an error in a consistent manner back to the client
# 
sub report_error {
    my ($self, $connection, $error, $path, $msg_id) = @_;

#    $self->log->warn("ERROR DATA: ".$error->[2]);
    my $msg = {
        route   => $path,
        msgId   => $msg_id,
        room    => $self->room,
        status  => $error->[0],
        message => $error->[1],
        content => {
            data        => $error->[2],
        },
    };
#    $self->log->warn(Dumper($msg));
#    $self->log->warn("GOT HERE 0 [".$error->[0]."] 1 [".$error->[1]."] 2 [".$error->[2]."]");
    eval {
        $msg = JSON->new->encode($msg);
    };
    if ($@) {
        $self->log->error("JSON ERROR ".$@);
    }
    $self->log->warn("MSG: ".$msg);

    $self->send($connection, $msg);
}

my $ERROR_ENV = "plack.app.websocket.error";

# This is where all the work gets done. 
#
sub call {
    my ($self, $env) = @_;

    my $log = $self->log;
    if ($env->{"psgi.run_once"}) {
        $log->debug("RUNNING IN A NON-PERSISTENT ENVIRONMENT");
    }
    else {
        $log->debug("RUNNING IN A PERSISTENT ENVIRONMENT");
    }


    if (!$env->{"psgi.streaming"} || !$env->{"psgi.nonblocking"} || !$env->{"psgix.io"}) {
        $env->{$ERROR_ENV} = "not supported by the PSGI server";
        return $self->on_error($env);
    }
    my $cv_conn = $self->ws_server->establish_psgi($env, $env->{"psgix.io"});
    return sub {
        my $responder = shift;
        $cv_conn->cb(sub {
            my ($cv_conn) = @_;
            my ($conn) = try { $cv_conn->recv };
            if (!$conn) {
                $env->{$ERROR_ENV} = "invalid request";
                _respond_via($responder, $self->on_error($env));
                return;
            }
            $self->on_establish(Plack::App::WebSocket::Connection->new($conn, $responder), $env);
        });
    };
}

sub _respond_via {
    my ($responder, $psgi_res) = @_;
    if (ref($psgi_res) eq "CODE") {
        $psgi_res->($responder);
    }
    else {
        $responder->($psgi_res);
    }
}


sub on_error {
    my ($self, $env) = @_;

    my $res = Plack::Response->new;
    $res->content_type("text/plain");
    if (!defined($env->{$ERROR_ENV})) {
        $res->status(500);
        $res->body("Unknown error");
    }
    elsif ($env->{$ERROR_ENV} eq "not supported by the PSGI server") {
        $res->status(500);
        $res->body("The server does not support WebSocket.");
    }
    elsif ($env->{$ERROR_ENV} eq "invalid request") {
        $res->status(400);
        $res->body("The request is invalid for a WebSocket request.");
    }
    else {
        $res->status(500);
        $res->body("Unknown error: $env->{$ERROR_ENV}");
    }
    $res->content_length(length($res->body));
    return $res->finalize;
}


1;

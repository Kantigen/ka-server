package KA::WebSocket;

use Moose;
use MooseX::NonMoose;

use Carp;
use AnyEvent;
use AnyEvent::WebSocket::Server;
use AnyEvent::WebSocket::Connection;
use Try::Tiny;
use JSON;
use Data::Dumper;
use Log::Log4perl;
use Time::HiRes qw(gettimeofday);

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

has client_data => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub log {
    my ($self) = @_;
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
        after       => 10,
        interval    => 10,
        cb          => sub {
            $self->heartbeat;
        },
    );
    # Persist the heartbeat timer.
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

    $self->log->debug("In Heartbeat 1");
    my $stats = $self->instance_stats;
    # Put the stats onto the stats queue
#    my $queue = KA::Queue->instance;
#    my $job = $queue->publish('stats', {
#        task        => 'websocket',
#        stats       => $stats,
#    },{
#        priority    => 1000,
#    });
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

    $self->log->info("XXXXXXXXXXXXXXXXXXXXXXXXX Sent: [$connection][$msg]");
    $self->log->debug("XXXXXXXXXX ".Dumper($connection));
    $self->incr_stat('stats_sent_messages');
    $connection->send($msg);
}

# Send a message to the one client in the 'context'
# 
sub render_json {
    my ($self, $context, $json) = @_;

    my $sent = JSON->new->encode($json);
    $self->send($context->connection, $sent);
    $self->log->info("********************* Sent");
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
    foreach my $key (keys %{$self->connections}) {
        $self->send($self->connections->{$key}, $sent);
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
    my ($self, $connection) = @_;

    $self->incr_stat('stats_new_connections');
    my $log = $self->log;
    $log->info("Establish: [$connection]");

    my $context = KA::WebSocket::Context->new({
        room        => $self->room,
        connection  => $connection,
        content     => {},
    });
    $log->debug("Establish");
    
    # Create initial blank data for the connection
    $self->connections->{$connection} = $connection;
    $self->client_data->{$connection} = {};

    $log->info("START: there are ".scalar(keys %{$self->connections}). " connections");
                
    my $reply = {
        room        => $self->room,
        route       => '/welcome',
        content     => $self->on_connect($context),
    };
    $log->debug("Establish");
    $self->render_json($context, $reply);

    my $state = {};
    
    $log->debug("Establish");
    
    $connection->on(
        each_message => sub {
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

    $msg = $msg->body;
    my $log = $self->log;

    $log->info("RCVD: [$connection] $msg");

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
            client_data     => $self->client_data->{$connection},
            client_code     => $client_code,
        });
        $log->debug("Call [$obj][$method]");

        # If the object requires the user to be logged in
#        if ($obj->must_be_logged_in and not 

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
    delete $self->connections->{$connection};
    delete $self->client_data->{$connection};
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

# This is the entry point for a WebSocket call
#
sub call {
    my ($self, $fh) = @_;

    $self->log->debug("got here [$fh]");
 
    $self->ws_server->establish($fh)->cb(sub {
        my ($arg) = @_;

        my $connection = eval { $arg->recv };

        if ($@) {
            warn "Invalid connection request: $@\n";
            close($fh);
            return;
        }
        $self->on_establish($connection);
    });
}

# This is responsible for handling beanstalk queue messages
#   typical messages looks like
#
#   {
#     route     => '/user/loginWithPassword',
#     user_id   => 123,
#     status    => 0,
#     message   => 'OK',
#     content   => {
#       username    => 'james_bond',
#       id          => 7,
#       email       => 'jb@mi5.gov.co.uk'
#     }
#   }
#
#   Note, although this is similar to the websocket messages
#   they do not call the same methods
#   
#   the user_id is used to identify which user the message
#   is for. By searching the connections it should be 
#   possible to find the connection key for that user.
#
#   If user_id is zero or not specified then it is a general
#   queue message.
#
sub queue {
    my ($self, $job) = @_;

    $self->log->debug("JOB: ".Dumper($job->payload));
    my $payload = $job->payload;
    my $connection;
    
    if ($payload->{user_id}) {
        # Then see if there is a connection with this user_id
        CONNECTION: foreach my $key (keys %{$self->client_data}) {
            if (my $user = $self->client_data->{$key}{user}) {
                $self->log->debug("QQQQ ".Dumper($user));
                if ($user->{id} == $payload->{user_id}) {
                    $connection = $self->connections->{$key};
                    last CONNECTION;
                }
            }
        }
        # if we can't find the user, then abort the job
        unless ($connection) {
            $self->log->info("Cannot find user ".$payload->{user_id});
            $job->delete;
            return;
        }
    }
    # Convert the route to a class and method
    my $path        = $payload->{route};
    my $content     = $payload->{content} || {};

    eval {
        my ($route, $method) = $path =~ m{(.*)/([^/]*)};
        $method = "mq_".$method;
        $route =~ s{/$}{};
        $route =~ s{^/}{};
        $route =~ s{/}{::};
        $route =~ s/([\w']+)/\u\L$1/g;      # Capitalize user::foo to User::Foo
        $self->log->debug("route = [$route]");
        my $obj;
        if ($route) {
            $route = ref($self)."::".$route;
            # TODO time how long an eval takes?

            eval "require $route";
            $obj = $route->new({});
        }
        else {
            $self->log->debug("ROUTE... [SELF!]");
            $route = $self;
            $obj = $self;
        }
        $self->log->debug("route = [$route]");
        my $context = KA::WebSocket::Context->new({
            room            => $self->room,
            connection      => $connection,
            content         => $content,
            client_data     => $connection ? $self->connections->{$connection} : {},
        });
        $self->log->debug("Call [$obj][$method] connection=[$connection]");

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

            $self->render_json($context, $reply);
        }
    }; 
    my @error;
    if ($@ and ref($@) eq 'ARRAY') {
        $self->log->error("ARRAY ERROR");
        @error = @{$@};
    }
    elsif ($@) {
        $self->log->error("UNKNOWN ERROR [".$@."]");
        @error = (
            1000,
            'unknown error',
            'please refer to server error log!',
        );
    }

    $job->delete;
}


1;

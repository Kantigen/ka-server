package KA::MessageQueue;

use Moose;
use MooseX::NonMoose;

use Carp;
use AnyEvent;
use Try::Tiny;
use JSON;
use Data::Dumper;
use Log::Log4perl;
use Time::HiRes qw(gettimeofday);

use KA::Queue;
use KA::MessageQueue::Context;

#--- Heartbeat timer
#
has hb_timer => (
    is      => 'rw',
);

#--- The name of the Message Queue Worker
#
has name => (
    is          => 'rw',
    required    => 1,
);

# Statistics attributes
#
has [qw(stats_sent_messages stats_bad_messages stats_bad_routes)] => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

has class_data => (
    is          => 'rw',
    isa         => 'Maybe[HashRef]',
    default     => sub { {} },
);

## Give the module a heartbeat (every 10 seconds)
##
#sub BUILD {
#    my ($self) = @_;
#
#    $self->log->info("BUILD MessageQueue $self");
#    my $ws = AnyEvent->timer(
#        after       => 10,
#        interval    => 10,
#        cb          => sub {
#            $self->heartbeat;
#        },
#    );
#    # Persist the heartbeat timer.
#    $self->hb_timer($ws);
#}


sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger( "KA::MessageQueue::".$self->name );
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

# Generate a hash for the statistics of this instance
# Note: this structure will be augmented by descendents
#
sub instance_stats {
    my ($self) = @_;

    my $stats = inner() || {};
    $stats->{time}          = time;
    $stats->{sent_messages} = $self->read_and_reset_stat('stats_sent_messages');
    $stats->{bad_messages}  = $self->read_and_reset_stat('stats_bad_messages');
    $stats->{bad_routes}    = $self->read_and_reset_stat('stats_bad_routes');

    return $stats;
}

##--- Heartbeat timer. Report stats and health
##
#sub heartbeat {
#    my ($self) = @_;
#
#    $self->log->debug("In Heartbeat 1");
#    my $stats = $self->instance_stats;
#    # Put the stats onto the stats queue
##    my $queue = KA::Queue->instance;
##    my $job = $queue->publish('stats', {
##        task        => 'websocket',
##        stats       => $stats,
##    },{
##        priority    => 1000,
##    });
#}


# This is responsible for handling beanstalk queue messages
#   typical messages looks like
#
#   {
#     route     => '/user/loginWithPassword',
#     user_id   => 123,
#     msg_id    => 345,
#     content   => {
#       username    => 'james_bond',
#       id          => 7,
#       email       => 'jb@mi5.gov.co.uk'
#     }
#   }
#
#   The user_id can be used to identify the user who requested
#   the message, although for internal messages this can be
#   undefined.
#
sub queue {
    my ($self, $job) = @_;

    $self->log->debug("JOB: ".Dumper($job->payload));
    my $payload = $job->payload;
   
    $self->route_call('bg_', $job);
}


sub route_call {
    my ($self, $prefix, $job) = @_;

    # Convert the route to a class and method
    my $payload     = $job->payload;
    my $path        = $payload->{route};
    my $content     = $payload->{content} || {};
    my $user_id     = $payload->{user_id} || 0;
    my $msg_id      = $payload->{msgId} || 0;

    eval {
        my ($route, $method) = $path =~ m{(.*)/([^/]*)};
        $method = $prefix.$method;
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
        my $class_data = $self->class_data;
        $class_data->{$route} = {} unless defined $class_data->{$route};

        $self->log->debug("route = [$route]");
        my $context = KA::MessageQueue::Context->new({
            name        => $self->name,
            content     => $content,
            msg_id      => $msg_id,
            user_id     => $user_id,
            class_data  => $class_data->{$route},
            job         => $job,
        });
        $self->log->debug("Call [$obj][$method]");

        #--- Call the method (we don't expect a return value
        #
        $obj->$method($context);
    }; 
    my @error;
    if ($@ and ref($@) eq 'ARRAY') {
        $self->log->error("ARRAY ERROR".Dumper($@));
        die "Cannot process job [$@]";
    }
    elsif ($@) {
        $self->log->error("UNKNOWN ERROR [".$@."]");
        die "Cannot process job [$@]";
    }
}


1;

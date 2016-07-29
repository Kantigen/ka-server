package KA::MessageQueue::Pubsub;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Time::HiRes qw(gettimeofday);

use KA::Queue;

sub log {
    my ($self) = @_;
    my $server = "User";
    return Log::Log4perl->get_logger( __PACKAGE__ );
}


#--- Publish a message
#
#   To publish a message sent it to the route '/pubsub/publish'.
#
#   {
#     route     => '/pubsub/publish',
#     ps_route  => '/my/route/',
#     channel   => 'my_channel',
#     content   => {
#       foo => 'bar',
#     }
#   }
#
#   The publisher will then forward the message to any subscriber
#   to channel 'my_channel'
#
#   {
#     route     => '/my/route',
#     content   => {
#       foo => 'bar',
#     }
#   }
#
#   If no-one is subscribed to a channel then the message will
#   be silently thrown away
#   
sub bg_publish {
    my ($self, $context) = @_;

    $self->log->debug("bg_publish: context[".$context->class_data."] ".Dumper($context));

    my $content = $context->content;
    my $message = $content->{message};
    my $channel = $content->{channel};
    my $pipes = $context->class_data->{pipes};

    my $queue = KA::Queue->instance;
    $self->log->debug("There are channels $pipes [".Dumper($pipes)."]");

    foreach my $pipe ( grep { m/^${channel}_(\d*)$/ } keys %$pipes ) {
        $self->log->debug("publishing to [$pipe]");
        $queue->publish({
            queue   => $pipe,
            payload => $message,
        });
    }

}

#--- Subscribe to a channel
#   On subscribing to a channel, a message queue pipe will be set
#   up specifically for this process, e.g. 'my_channel_2' will then
#   accept any messages published to the 'my_channel' channel.
#
#   Anyone else subscribing to this channel will listen on a new
#   pipe, e.g. 'my_channel_3'
#
#   {
#     route     => '/pubsub/subscribe',
#     pipe      => 'my_channel_2',
#   }
#   
sub bg_subscribe {
    my ($self, $context) = @_;

    $self->log->debug("bg_subscribe: context[".$context->class_data."] ".Dumper($context));
    my $content = $context->content;
    my $pipe    = $content->{pipe};

    $context->class_data->{pipes}{$pipe} = 1;
    $self->log->debug("Added channel ".$context->class_data->{pipes}." [".Dumper($context->class_data)."]");
}

#--- Unsubscribe from a channel
#   On unsubscribing, the publisher will stop sending to that
#   pipe. 
#
#   {
#     route     => '/pubsub/unsubscribe'
#     pipe      => 'my_channel_2',
#   }
#
sub bg_unsubscribe {
    my ($self, $context) = @_;

    $self->log->debug("bg_unsubscribe: context[".$context->class_data."] ".Dumper($context));
    my $content = $context->content;
    my $pipe    = $content->{pipe};
    my $pipes   = $context->class_data->{pipes};
    delete $pipes->{$pipe};
    $self->log->debug("Removed channel $pipes [".Dumper($context->class_data)."]");

}
1;

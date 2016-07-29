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

    $self->log->debug("bg_publish: ".Dumper($context));
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
#     channel   => 'my_channel_2',
#   }
#   
sub bg_subscribe {
    my ($self, $context) = @_;

    $self->log->debug("bg_subscribe: ".Dumper($context));
}

#--- Unsubscribe from a channel
#   On unsubscribing, the publisher will stop sending to that
#   pipe. 
#
#   {
#     route     => '/pubsub/unsubscribe'
#     channel   => 'my_channel_2',
#   }
#
sub bg_unsubscribe {
    my ($self, $context) = @_;

    $self->log->debug("bg_unsubscribe: ".Dumper($context));
}
1;

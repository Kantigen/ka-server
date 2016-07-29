package KA::PubSub;

use MooseX::Singleton;
use KA::Queue;

use namespace::autoclean;

# Interface to the PubSub subscription service.
#
# This is currently implemented as a 'fan-out' using beanstalk
# queues. Beanstalk does not offer pub-sub directly so this could
# be considered a bit of a hack.
#
# Look in the future to using something like the RabbitMQ Pub/Sub
# options instead.
#
# Conversely, we have tools in place to monitor and manage beanstalk
# so adding yet another service may just give added complexity
#


#--- Publish
#
#   To publish a message to a channel.
#
#   channel => 'my_channel'
#
#   message =>
#   {
#     route     => 'my/route',
#     content   => {
#       foo => 'bar',
#     }
#   }
#
sub publish {
    my ($self, $channel, $message) = @_;

    my $queue = KA::Queue->instance;

    my $content = {
        channel     => $channel,
        message     => $message,
    };

    my $job = $queue->publish({
        queue   => 'bg_pubsub',
        payload => {
            route   => '/pubsub/publish',
            content => $content,
        },
    });

}


#--- Subscribe
#
#   Subscribe to a channel 'my_channel'
#
#   Thereafter any messages to that channel will be
#   forwarded to a unique pipe, e.g. 'my_channel_2'
#   which the subscriber should listen to.
#
sub subscribe {
    my ($self, $channel) = @_;

    my $cache = KA::Cache->instance;

    my $id = $cache->incr('pubsub', $channel);

    my $pipe = "${channel}_$id";
    my $queue = KA::Queue->instance;
    $queue->watch($queue);

    $queue->publish({
        queue   => 'bg_pubsub',
        payload => {
            route   => '/pubsub/subscribe',
            content => {
                pipe => $pipe,
            },
        },
    });

    return $pipe;

}

#--- Unsubscribe
#
#   Unsubscribe to a channel
#
#   Give the 'pipe' that is listened to, e.g. 'my_channel_2'
#   and the channel 'my_channel' will be unsubscribed from
#   and the pipe 'my_channel_2' will no longer receive any
#   messages.
#
sub unsubscribe {
    my ($self, $pipe) = @_;

    my $queue = KA::Queue->instance;

    $queue->publish({
        queue   => 'bg_pubsub',
        payload => {
            route   => '/pubsub/unsubscribe',
            content => {
                pipe => $pipe,
            },
        },
    });

    $queue->ignore($queue);
}

__PACKAGE__->meta->make_immutable;


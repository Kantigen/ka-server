package KA::PubSub;

use MooseX::Singleton;

use namespace::autoclean;

# Interface to the PubSub subscription service.
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
    my ($self, $queue, $channel) = @_;

    my $pipe = "${channel}_2";
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
    my ($self, $queue, $pipe) = @_;

}

__PACKAGE__->meta->make_immutable;


package KA::WebSocket::Building;

use Moose;
use Log::Log4perl;
use Data::Dumper;

use KA::Queue;
use KA::Config;

# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        message     => 'Welcome to KA Building server',
    };
}

sub log {
    my ($self) = @_;
    my $server = "Building";
    return Log::Log4perl->get_logger( "WS::$server" );
}

#--- When a building completes it's upgrade, a message is published
#   On the pub-sub queue and this is passed on to any connected user
#   who owns that building.
#
#   If the user has multiple clients, the info is passed on to all
#   clients. We do not (as yet) filter based on the body id so the
#   client will receive notifications for all buildings completed in
#   their empire
#
sub mq_upgraded {
    my ($self, $context) = @_;

    return $context->content;
}

1;

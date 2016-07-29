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

sub mq_upgraded {
    my ($self) = @_;

    $self->log->debug("XXXXXXXXXXXX Building upgraded");
}

1;

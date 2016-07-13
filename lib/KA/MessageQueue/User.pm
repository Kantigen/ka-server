package KA::MessageQueue::User;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;
use Time::HiRes qw(gettimeofday);

use KA::SDB;
use KA::Queue;

sub log {
    my ($self) = @_;
    my $server = "User";
    return Log::Log4perl->get_logger( "WS::$server" );
}

#--- Receive a Message Queue message
#
sub bg_hello {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    $log->debug("BG_HELLO: ".Dumper($context));
}

1;

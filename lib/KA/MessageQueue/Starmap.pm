package KA::MessageQueue::Starmap;

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
    return Log::Log4perl->get_logger( "KA::MessageQueue::Starmap" );
}

#--- Receive a getMapChunk request
#
sub mq_getMapChunk {
    my ($self, $context) = @_;

    $self->log->debug("MQ - getStarMap: ".Dumper($context));

















}

1;

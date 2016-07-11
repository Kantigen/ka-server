package KA::MessageQueue::Fleet;

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
    return Log::Log4perl->get_logger( __PACKAGE__ );
}

#--- Fleet arrives at destination
#
sub bg_arrives {
    my ($self, $context) = @_;

    $self->log->debug("BG_Fleet arrives : ".Dumper($context));
}

#--- Fleet finishes Construction Upgrade
#
sub bg_finishConstruction {
    my ($self, $context) = @_;

    $self->log->debug("BG_Fleet finishConstruction : ".Dumper($context));
}

1;

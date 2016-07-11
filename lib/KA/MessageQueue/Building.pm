package KA::MessageQueue::Building;

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

#--- Building finishes Upgrade
#
sub bg_finishUpgrade {
    my ($self, $context) = @_;

    $self->log->debug("BG_Building finishUpgrade : ".Dumper($context));
}

#--- Building finishes Work
#
sub bg_finishWork {
    my ($self, $context) = @_;

    $self->log->debug("BG_Building finishWork : ".Dumper($context));
}

1;

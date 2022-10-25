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
sub bg_arrive {
    my ($self, $context) = @_;

    $self->log->debug("BG_Fleet arrive : ".Dumper($context));
    my $db = KA::SDB->instance->db;

    my $fleet_id = $context->content->{fleet_id};
    my $fleet = $db->resultset('Fleet')->find($fleet_id);
    if (defined $fleet) {
        $fleet->arrive;
    }
    else {
        $self->log->error("Cannot find fleet - $fleet_id");
    }
}

#--- Fleet finishes Construction Upgrade
#
sub bg_finishConstruction {
    my ($self, $context) = @_;

    $self->log->debug("BG_Fleet finishConstruction : ".Dumper($context));
    my $db = KA::SDB->instance->db;

    my $fleet_id = $context->content->{fleet_id};
    my $fleet = $db->resultset('Fleet')->find($fleet_id);
    if (defined $fleet) {
        $fleet->finish_construction;
    }
    else {
        $self->log->error("Cannot find fleet - $fleet_id");
    }
}

1;

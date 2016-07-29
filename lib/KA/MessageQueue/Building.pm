package KA::MessageQueue::Building;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;
use Time::HiRes qw(gettimeofday);

use KA::SDB;
use KA::Queue;
use KA::PubSub;

sub log {
    my ($self) = @_;
    my $server = "User";
    return Log::Log4perl->get_logger( __PACKAGE__ );
}

sub db {
    my ($self) = @_;

    return KA::SDB->instance->db;
}

#--- Building finishes Upgrade
#
sub bg_finishUpgrade {
    my ($self, $context) = @_;

    $self->log->debug("BG_Building finishUpgrade : ".Dumper($context));
    my $content = $context->content;

    my $building = $self->db->resultset('Building')->find({ id => $content->{building_id} });
    if (defined $building) {
        $building->finish_upgrade;
    }
    else {
        $self->log->error("Could not find building ID [".$content->{building_id}."]");
    }
    # Publish the building completion (in case anyone is interested)
    my $pubsub = KA::PubSub->instance;
    $pubsub->publish('ps_building', {
        route   => '/building/upgraded',
        user_id => 1,       # TODO This is just until we link empire and user IDs
        content => {
            building_id => $building->id,
            body_id     => $building->body_id,
            empire_id   => $building->body->empire_id,
        },
    });
}

#--- Building finishes Work
#
sub bg_finishWork {
    my ($self, $context) = @_;

    $self->log->debug("BG_Building finishWork : ".Dumper($context));
    my $content = $context->content;

    my $building = $self->db->resultset('Building')->find({ id => $content->{building_id} });
    if (defined $building) {
        $building->finish_work;
    }
    else {
        $self->log->error("Could not find building ID [".$content->{building_id}."]");
    }
}

1;

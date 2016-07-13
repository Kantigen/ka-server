package KA::RPC::Building::EssentiaVein;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/essentiavein';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::EssentiaVein';
}

around view => sub {
    my ($orig, $self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, $session, $building);

    my $body = $building->body;
    $out->{building}{drain_capable} = $body->happiness >= 0 ?
        int($building->work_seconds_remaining() / (30 * 24 * 60 * 60)) : 0;

    return $out;
};

sub drain {
    my ($self, $session_id, $building_id, $times) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;

    my $body = $building->body;
    confess [1010, "Cannot drain essentia from unhappy mines."]
        unless $body->happiness >= 0;

    $times ||= 1;
    my $days = $times * 30;

    my $work_reduction = $days * 24 * 60 * 60;
    confess [1010, "The essentia vein does not have $days days left on it."]
        unless $building->work_seconds_remaining > $work_reduction;

    $empire->add_essentia({ 
                    amount  => $days,
                    reason  => "Essentia Vein (drain: $days)",
                });
    $empire->update;

    my $work_ends = $building->work_ends->subtract(seconds => $work_reduction);
    $building->reschedule_work($work_ends);
    $building->update;

    return $self->view($session_id, $building_id);
}

__PACKAGE__->register_rpc_method_names(qw(drain));

no Moose;
__PACKAGE__->meta->make_immutable;


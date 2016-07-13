package KA::RPC::Building::StationCommand;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

with 'KA::Role::IncomingSupplyChains';

sub app_url {
    return '/stationcommand';
}

sub model_class {
    return 'KA::DB::Result::Building::Module::StationCommand';
}

around 'view' => sub {
    my ($orig, $self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, $session, $building);
    $out->{planet} = $building->body->get_status($empire);
    $out->{ore} = $building->body->get_ore_status;
    $out->{food} = $building->body->get_food_status;
    $out->{next_colony_cost} = $empire->next_colony_cost("colony_ship");
    $out->{next_station_cost} = $empire->next_colony_cost("space_station");
    return $out;
};

sub view_plans {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my @out;
    my $sorted_plans = $building->body->sorted_plans;
    foreach my $plan (@$sorted_plans) {
        my $item = {
            quantity            => $plan->quantity,
            name                => $plan->class->name,
            level               => $plan->level,
            extra_build_level   => $plan->extra_build_level,
        };
        push @out, $item;
    }

    return {
        status  => $self->format_status($session, $building->body),
        plans   => \@out,
    }
}

__PACKAGE__->register_rpc_method_names(qw(view_plans view_incoming_supply_chains));



no Moose;
__PACKAGE__->meta->make_immutable;


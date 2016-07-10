package KA::AI::Cult;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::AI';

use constant empire_id  => -5;

has viable_colonies => (
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        return KA->db->resultset('KA::DB::Result::Map::Body')->search(
            { empire_id => undef, orbit => 3, size => { between => [30,50]}},
            );
    }
);

sub empire_defaults {
    return {
        name                    => 'Cult of the Fissure',
        status_message          => 'Despair, Misfortune, Woe!',
        description             => 'Break on thru to the other side.',
        species_name            => 'Cult of the Fissure',
        species_description     => 'Only by releasing the fissures can we free ourselves.',
        min_orbit               => 3,
        max_orbit               => 3,
        manufacturing_affinity  => 1, 
        deception_affinity      => 1,
        research_affinity       => 1,
        management_affinity     => 1,
        farming_affinity        => 1,
        mining_affinity         => 1,
        science_affinity        => 1,
        environmental_affinity  => 1,
        political_affinity      => 1,
        trade_affinity          => 1,
        growth_affinity         => 1,
        is_isolationist         => 0,
    };
}

sub colony_structures {
    return (
        ['KA::DB::Result::Building::Waste::Sequestration', 30],
        ['KA::DB::Result::Building::Intelligence', 20],
        ['KA::DB::Result::Building::Security', 20],
        ['KA::DB::Result::Building::Espionage', 20],
        ['KA::DB::Result::Building::Shipyard', 10],
        ['KA::DB::Result::Building::SpacePort', 20],
        ['KA::DB::Result::Building::SpacePort', 20],
        ['KA::DB::Result::Building::SpacePort', 20],
        ['KA::DB::Result::Building::SpacePort', 20],
        ['KA::DB::Result::Building::SpacePort', 20],
        ['KA::DB::Result::Building::Observatory',10],
        ['KA::DB::Result::Building::Archaeology',10],
        ['KA::DB::Result::Building::Trade', 10],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::SAW',20],
        ['KA::DB::Result::Building::Permanent::Volcano',25],
        ['KA::DB::Result::Building::Permanent::NaturalSpring',25],
        ['KA::DB::Result::Building::Permanent::InterDimensionalRift',25],
        ['KA::DB::Result::Building::Permanent::GeoThermalVent',25],
        ['KA::DB::Result::Building::Permanent::KalavianRuins',10],
        ['KA::DB::Result::Building::Permanent::MalcudField',24],
        ['KA::DB::Result::Building::Permanent::AlgaePond',24],
        ['KA::DB::Result::Building::Permanent::BlackHoleGenerator',30],
        ['KA::DB::Result::Building::Permanent::Ravine',30],
        ['KA::DB::Result::Building::Water::Storage',30],
        ['KA::DB::Result::Building::Ore::Storage',30],
        ['KA::DB::Result::Building::Energy::Reserve',30],
        ['KA::DB::Result::Building::Food::Reserve',30],
        ['KA::DB::Result::Building::Food::Corn',15],
        ['KA::DB::Result::Building::Food::Wheat',15],
        ['KA::DB::Result::Building::Food::Dairy',15],
);
}

sub spy_missions {
# Missions run by script
    return (
        'Appropriate Resources',
        'Sabotage Resources',
        'Sabotage Infrastructure',
        'Incite Rebellion',
        'Sabotage Probes',
        'Incite Rebellion',
    );
}

sub ship_building_priorities {
    return (
        ['cargo_ship', 14],
        ['probe', 5],
    );
}

sub run_hourly_colony_updates {
    my ($self, $colony) = @_;
    $self->demolish_bleeders($colony);
    $self->set_defenders($colony);
    if ($colony->id == $colony->empire->home_planet_id) {
        $self->pod_check($colony, 25);
        $self->repair_buildings($colony);
    }
#    $self->train_spies($colony);
#    $self->build_ships($colony);
#    $self->run_missions($colony);
}

no Moose;
__PACKAGE__->meta->make_immutable;

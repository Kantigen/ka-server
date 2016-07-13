package KA::AI::Trelvestian;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::AI';

use constant empire_id  => -3;

has viable_colonies => (
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        return KA->db->resultset('KA::DB::Result::Map::Body')->search(
            { empire_id => undef, orbit => { between => [5,6] }, size => { between => [50,75]}},
            );
    }
);

sub empire_defaults {
    return {
        name                    => 'Trelvestian Sveitarfélagi',
        status_message          => 'Grafa Essentia',
        description             => 'Þú koma sjúkdómnum. Þú koma dauða. Láttu okkur vera.',
        species_name            => 'Trelvestivð',
        species_description     => 'Við viljum vera í friði.',
        min_orbit               => 5,
        max_orbit               => 6,
        manufacturing_affinity  => 6, 
        deception_affinity      => 4,
        research_affinity       => 1,
        management_affinity     => 1,
        farming_affinity        => 7,
        mining_affinity         => 7,
        science_affinity        => 7,
        environmental_affinity  => 7,
        political_affinity      => 1,
        trade_affinity          => 1,
        growth_affinity         => 1,
        is_isolationist         => 0,
    };
}

sub colony_structures {
    return (
        ['KA::DB::Result::Building::Permanent::EssentiaVein',28],
        ['KA::DB::Result::Building::Permanent::GeoThermalVent',30],
        ['KA::DB::Result::Building::Permanent::GratchsGauntlet',30],
        ['KA::DB::Result::Building::Permanent::NaturalSpring',30],
        ['KA::DB::Result::Building::Permanent::Volcano',30],
        ['KA::DB::Result::Building::Permanent::AlgaePond',30],
        ['KA::DB::Result::Building::Permanent::BeeldebanNest',30],
        ['KA::DB::Result::Building::Permanent::MalcudField',30],
        ['KA::DB::Result::Building::Permanent::GreatBallOfJunk',11],
        ['KA::DB::Result::Building::Permanent::JunkHengeSculpture',12],
        ['KA::DB::Result::Building::Permanent::MetalJunkArches',20],
        ['KA::DB::Result::Building::Permanent::KalavianRuins',30],
        ['KA::DB::Result::Building::Permanent::OracleOfAnid',10],
        ['KA::DB::Result::Building::Permanent::InterDimensionalRift',30],
        ['KA::DB::Result::Building::Intelligence', 25],
        ['KA::DB::Result::Building::Security', 30],
        ['KA::DB::Result::Building::MunitionsLab', 25],
        ['KA::DB::Result::Building::Shipyard',22],
        ['KA::DB::Result::Building::Shipyard',22],
        ['KA::DB::Result::Building::Shipyard',22],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::SpacePort', 25],
        ['KA::DB::Result::Building::PilotTraining',25],
        ['KA::DB::Result::Building::Energy::Reserve', 30],
        ['KA::DB::Result::Building::Food::Reserve', 30],
        ['KA::DB::Result::Building::Ore::Storage', 30],
        ['KA::DB::Result::Building::Water::Storage', 30],
        ['KA::DB::Result::Building::Waste::Sequestration', 30],
        ['KA::DB::Result::Building::Waste::Exchanger', 20],
        ['KA::DB::Result::Building::Waste::Exchanger', 20],
        ['KA::DB::Result::Building::Food::Beeldeban',20],
        ['KA::DB::Result::Building::Food::Root',20],
        ['KA::DB::Result::Building::Food::Beeldeban',20],
        ['KA::DB::Result::Building::Food::Root',20],
        ['KA::DB::Result::Building::Ore::Refinery',20],
        ['KA::DB::Result::Building::Ore::Mine',20],
        ['KA::DB::Result::Building::Ore::Mine',20],
        ['KA::DB::Result::Building::Ore::Mine',20],
        ['KA::DB::Result::Building::Ore::Mine',20],
        ['KA::DB::Result::Building::Energy::Singularity',20],
        ['KA::DB::Result::Building::Energy::Singularity',20],
        ['KA::DB::Result::Building::Energy::Fusion',20],
        ['KA::DB::Result::Building::Energy::Fusion',20],
        ['KA::DB::Result::Building::Water::Production',20],
        ['KA::DB::Result::Building::Water::Production',20],
        ['KA::DB::Result::Building::Water::AtmosphericEvaporator',20],
        ['KA::DB::Result::Building::Water::AtmosphericEvaporator',20],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::SAW',30],
        ['KA::DB::Result::Building::Observatory', 10],
    );
}

sub extra_glyph_buildings {
    return {
        quantity    => 0,
        min_level   => 1,
        max_level   => 5,
    }
}

sub spy_missions {
    return (
        'Appropriate Resources',
        'Sabotage Infrastructure',
    );
}

sub ship_building_priorities {
    return (
        ['drone', 50],
        ['fighter', 50],
        ['probe', 5],
        ['sweeper', 50],
        ['snark',  5],
        ['snark2',15],
        ['snark3',50],
    );
}

sub run_hourly_colony_updates {
    my ($self, $colony) = @_;
    $self->demolish_bleeders($colony);
    $self->kill_prisoners($colony, 96);
    $self->set_defenders($colony);
    $self->pod_check($colony, 25);
    $self->repair_buildings($colony);
    $self->train_spies($colony, 100, 1);
    $self->build_ships($colony);
    $self->run_missions($colony);
}

no Moose;
__PACKAGE__->meta->make_immutable;

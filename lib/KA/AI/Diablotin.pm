package KA::AI::Diablotin;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::AI';

use constant empire_id  => -7;

has viable_colonies => (
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        return KA->db->resultset('KA::DB::Result::Map::Body')->search(
            { empire_id => undef, orbit => 7, size => { between => [45,70]}},
            );
    }
);

sub empire_defaults {
    return {
        name                    => 'Diablotin',
        status_message          => 'Vous tes le bouffon!',
        description             => 'La plaisanterie est sur toi.',
        species_name            => 'Diablotin',
        species_description     => 'Nous aimons nous amuser.',
        min_orbit               => 7,
        max_orbit               => 7,
        manufacturing_affinity  => 7, 
        deception_affinity      => 7,
        research_affinity       => 1,
        management_affinity     => 1,
        farming_affinity        => 6,
        mining_affinity         => 1,
        science_affinity        => 7,
        environmental_affinity  => 6,
        political_affinity      => 6,
        trade_affinity          => 1,
        growth_affinity         => 1,
        is_isolationist         => 0,
    };
}

sub colony_structures {
    return (
        ['KA::DB::Result::Building::Archaeology',10],
        ['KA::DB::Result::Building::CloakingLab', 15],
        ['KA::DB::Result::Building::Energy::Hydrocarbon',15],
        ['KA::DB::Result::Building::Energy::Singularity',15],
        ['KA::DB::Result::Building::Energy::Reserve', 15],
        ['KA::DB::Result::Building::Energy::Waste',15],
        ['KA::DB::Result::Building::Food::Algae',15],
        ['KA::DB::Result::Building::Food::Algae',15],
        ['KA::DB::Result::Building::Food::Algae',15],
        ['KA::DB::Result::Building::Food::Burger',15],
        ['KA::DB::Result::Building::Food::Malcud',15],
        ['KA::DB::Result::Building::Food::Malcud',15],
        ['KA::DB::Result::Building::Food::Malcud',15],
        ['KA::DB::Result::Building::Food::Malcud',15],
        ['KA::DB::Result::Building::Food::Reserve', 15],
        ['KA::DB::Result::Building::Food::Syrup',15],
        ['KA::DB::Result::Building::Intelligence', 10],
        ['KA::DB::Result::Building::LuxuryHousing',15],
        ['KA::DB::Result::Building::MunitionsLab', 12],
        ['KA::DB::Result::Building::Observatory',10],
        ['KA::DB::Result::Building::Ore::Mine',15],
        ['KA::DB::Result::Building::Ore::Mine',15],
        ['KA::DB::Result::Building::Ore::Refinery',15],
        ['KA::DB::Result::Building::Ore::Storage',15],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::SAW',10],
        ['KA::DB::Result::Building::Security', 15],
        ['KA::DB::Result::Building::Shipyard', 8],
        ['KA::DB::Result::Building::Shipyard', 8],
        ['KA::DB::Result::Building::Shipyard', 8],
        ['KA::DB::Result::Building::SpacePort', 15],
        ['KA::DB::Result::Building::SpacePort', 15],
        ['KA::DB::Result::Building::SpacePort', 15],
        ['KA::DB::Result::Building::SpacePort', 15],
        ['KA::DB::Result::Building::Waste::Digester',15],
        ['KA::DB::Result::Building::Waste::Digester',15],
        ['KA::DB::Result::Building::Waste::Digester',15],
        ['KA::DB::Result::Building::Waste::Sequestration', 20],
        ['KA::DB::Result::Building::Waste::Treatment',15],
        ['KA::DB::Result::Building::Waste::Treatment',15],
        ['KA::DB::Result::Building::Water::AtmosphericEvaporator',15],
        ['KA::DB::Result::Building::Water::Reclamation',15],
        ['KA::DB::Result::Building::Water::Reclamation',15],
        ['KA::DB::Result::Building::Water::Reclamation',15],
        ['KA::DB::Result::Building::Water::Storage',15],
    );
}

sub extra_glyph_buildings {
    my $return = {
        quantity    => 1,
        min_level   => 10,
        max_level   => 30,
    };
    $return->{findable} = [
        "KA::DB::Result::Building::Permanent::AmalgusMeadow",
        "KA::DB::Result::Building::Permanent::BeeldebanNest",
        "KA::DB::Result::Building::Permanent::DentonBrambles",
        "KA::DB::Result::Building::Permanent::GeoThermalVent",
        "KA::DB::Result::Building::Permanent::GratchsGauntlet",
        "KA::DB::Result::Building::Permanent::GreatBallOfJunk",
        "KA::DB::Result::Building::Permanent::InterDimensionalRift",
        "KA::DB::Result::Building::Permanent::NaturalSpring",
        "KA::DB::Result::Building::Permanent::Volcano",
        "KA::DB::Result::Building::Permanent::AlgaePond",
        "KA::DB::Result::Building::Permanent::BlackHoleGenerator",
        "KA::DB::Result::Building::Permanent::CitadelOfKnope",
        "KA::DB::Result::Building::Permanent::CrashedShipSite",
        "KA::DB::Result::Building::Permanent::KalavianRuins",
        "KA::DB::Result::Building::Permanent::LapisForest",
        "KA::DB::Result::Building::Permanent::LibraryOfJith",
        "KA::DB::Result::Building::Permanent::MalcudField",
        "KA::DB::Result::Building::Permanent::OracleOfAnid",
        "KA::DB::Result::Building::Permanent::PantheonOfHagness",
        "KA::DB::Result::Building::Permanent::Ravine",
        "KA::DB::Result::Building::Permanent::TempleOfTheDrajilites",
    ];
    return $return;
}

sub spy_missions {
    return (
        'Appropriate Resources',
        'Sabotage Resources',
    );
}

sub ship_building_priorities {
    return (
        ['drone', 14],
        ['probe', 4],
        ['thud', 18],
        ['placebo2', 18],
        ['placebo3', 18],
        ['placebo', 18],
        ['bleeder', 18],
    );
}

sub run_hourly_colony_updates {
    my ($self, $colony) = @_;
    $self->demolish_bleeders($colony);
    $self->kill_prisoners($colony, 24);
    $self->set_defenders($colony);
    $self->pod_check($colony, 15);
    $self->repair_buildings($colony);
    $self->train_spies($colony, 50);
    $self->build_ships($colony);
    $self->run_missions($colony);
}

no Moose;
__PACKAGE__->meta->make_immutable;

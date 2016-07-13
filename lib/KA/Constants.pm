package KA::Constants;

use strict;
use base 'Exporter';

use constant SLUG        => 1.30;
use constant SLOW        => 1.35;
use constant MED         => 1.40;
use constant FAST        => 1.45;
use constant EXTREME     => 1.50;
use constant GROWTH      => MED;
use constant GROWTH_N    => MED;
use constant GROWTH_S    => SLOW;
use constant GROWTH_F    => FAST;
use constant INFLATION   => FAST;
use constant INFLATION_N => FAST;
use constant INFLATION_S => MED;
use constant INFLATION_F => EXTREME;
use constant CONSUME     => MED;
use constant CONSUME_N   => MED;
use constant CONSUME_S   => SLOW;
use constant CONSUME_F   => FAST;
use constant WASTE       => MED;
use constant WASTE_N     => MED;
use constant WASTE_S     => SLOW;
use constant WASTE_F     => FAST;
use constant HAPPY       => MED;
use constant HAPPY_N     => MED;
use constant HAPPY_S     => SLOW;
use constant HAPPY_F     => FAST;

# A greater time dilator for each level
use constant TINFLATE    => 1.75;
use constant TINFLATE_N  => 1.75;
use constant TINFLATE_S  => 1.7;
use constant TINFLATE_F  => 1.8;

use constant SECONDS_IN_A_DAY => 60 * 60 * 24;
use constant MINIMUM_EXERTABLE_INFLUENCE => 10;
use constant FOOD_TYPES => (qw(cheese bean lapis potato apple root corn cider wheat bread soup chip pie pancake milk meal algae syrup fungus burger shake beetle));
use constant ORE_TYPES => (qw(rutile chromite chalcopyrite galena gold uraninite bauxite goethite halite gypsum trona kerogen methane anthracite sulfur zircon monazite fluorite beryl magnetite));
use constant BUILDABLE_CLASSES => (qw(
    KA::RPC::Building::SSLa
    KA::RPC::Building::SSLb
    KA::RPC::Building::SSLc
    KA::RPC::Building::SSLd
    KA::RPC::Building::DistributionCenter
    KA::RPC::Building::AtmosphericEvaporator
    KA::RPC::Building::MetalJunkArches
    KA::RPC::Building::SpaceJunkPark
    KA::RPC::Building::SAW
    KA::RPC::Building::PyramidJunkSculpture
    KA::RPC::Building::JunkHengeSculpture
    KA::RPC::Building::GreatBallOfJunk
    KA::RPC::Building::ThemePark
    KA::RPC::Building::MissionCommand
    KA::RPC::Building::CloakingLab
    KA::RPC::Building::MunitionsLab
    KA::RPC::Building::LuxuryHousing
    KA::RPC::Building::PilotTraining
    KA::RPC::Building::Capitol
    KA::RPC::Building::Stockpile
    KA::RPC::Building::Algae
    KA::RPC::Building::Apple
    KA::RPC::Building::Bean
    KA::RPC::Building::Beeldeban
    KA::RPC::Building::Bread
    KA::RPC::Building::Burger
    KA::RPC::Building::Cheese
    KA::RPC::Building::Chip
    KA::RPC::Building::Cider
    KA::RPC::Building::Corn
    KA::RPC::Building::CornMeal
    KA::RPC::Building::Dairy
    KA::RPC::Building::Denton
    KA::RPC::Building::Development
    KA::RPC::Building::Embassy
    KA::RPC::Building::EnergyReserve
    KA::RPC::Building::Entertainment
    KA::RPC::Building::Espionage
    KA::RPC::Building::Fission
    KA::RPC::Building::FoodReserve
    KA::RPC::Building::Fusion
    KA::RPC::Building::GasGiantLab
    KA::RPC::Building::Geo
    KA::RPC::Building::Hydrocarbon
    KA::RPC::Building::Intelligence
    KA::RPC::Building::IntelTraining
    KA::RPC::Building::Lapis
    KA::RPC::Building::Malcud
    KA::RPC::Building::MayhemTraining
    KA::RPC::Building::MercenariesGuild
    KA::RPC::Building::Mine
    KA::RPC::Building::MiningMinistry
    KA::RPC::Building::Network19
    KA::RPC::Building::Observatory
    KA::RPC::Building::OreRefinery
    KA::RPC::Building::OreStorage
    KA::RPC::Building::Pancake
    KA::RPC::Building::Park
    KA::RPC::Building::Pie
    KA::RPC::Building::PoliticsTraining
    KA::RPC::Building::Potato
    KA::RPC::Building::Propulsion
    KA::RPC::Building::Oversight
    KA::RPC::Building::Security
    KA::RPC::Building::Shake
    KA::RPC::Building::Shipyard
    KA::RPC::Building::Singularity
    KA::RPC::Building::Soup
    KA::RPC::Building::SpacePort
    KA::RPC::Building::Syrup
    KA::RPC::Building::TerraformingLab
    KA::RPC::Building::TheftTraining
    KA::RPC::Building::GeneticsLab
    KA::RPC::Building::Archaeology
    KA::RPC::Building::Trade
    KA::RPC::Building::Transporter
    KA::RPC::Building::University
    KA::RPC::Building::WasteEnergy
    KA::RPC::Building::WasteExchanger
    KA::RPC::Building::WasteRecycling
    KA::RPC::Building::WasteSequestration
    KA::RPC::Building::WasteDigester
    KA::RPC::Building::WasteTreatment
    KA::RPC::Building::WaterProduction
    KA::RPC::Building::WaterPurification
    KA::RPC::Building::WaterReclamation
    KA::RPC::Building::WaterStorage
    KA::RPC::Building::Wheat
    ));
use constant SPACE_STATION_MODULES => (qw(
    KA::RPC::Building::ArtMuseum
    KA::RPC::Building::CulinaryInstitute
    KA::RPC::Building::IBS
    KA::RPC::Building::OperaHouse
    KA::RPC::Building::Parliament
    KA::RPC::Building::PoliceStation
    KA::RPC::Building::StationCommand
    KA::RPC::Building::Warehouse
    ));
use constant SHIP_TYPES => (qw( probe short_range_colony_ship colony_ship spy_pod cargo_ship space_station 
                             smuggler_ship mining_platform_ship terraforming_platform_ship surveyor
                             gas_giant_settlement_ship scow scow_fast scow_large scow_mega dory freighter snark snark2 snark3 thud
                             supply_pod supply_pod2 supply_pod3 supply_pod4 supply_pod5
                             drone fighter spy_shuttle observatory_seeker security_ministry_seeker 
                             spaceport_seeker excavator detonator scanner barge hulk hulk_fast hulk_huge galleon stake
                             placebo placebo2 placebo3 placebo4 placebo5 placebo6 bleeder sweeper fissure_sealer
                             ));
use constant SHIP_TRADE_TYPES => (qw(
    cargo_ship smuggler_ship freighter dory barge galleon hulk hulk_huge hulk_fast
));
use constant SHIP_WASTE_TYPES => (qw(
    scow scow_fast scow_large scow_mega
));
use constant SHIP_SINGLE_USE_TYPES => (qw( probe short_range_colony_ship colony_ship spy_pod space_station 
                                        mining_platform_ship terraforming_platform_ship surveyor
                                        gas_giant_settlement_ship snark snark2 snark3 thud
                                        supply_pod supply_pod2 supply_pod3 supply_pod4 supply_pod5
                                        drone spy_shuttle observatory_seeker security_ministry_seeker 
                                        spaceport_seeker excavator detonator scanner stake
                                        placebo placebo2 placebo3 placebo4 placebo5 placebo6 bleeder fissure_sealer
                                        ));
our @EXPORT_OK = qw(
    GROWTH
    GROWTH_N
    GROWTH_S
    GROWTH_F
    INFLATION
    INFLATION_N
    INFLATION_S
    INFLATION_F
    CONSUME
    CONSUME_N
    CONSUME_S
    CONSUME_F
    WASTE
    WASTE_N
    WASTE_S
    WASTE_F
    HAPPY
    HAPPY_N
    HAPPY_S
    HAPPY_F
    TINFLATE
    TINFLATE_N
    TINFLATE_S
    TINFLATE_F
    SECONDS_IN_A_DAY
    MINIMUM_EXERTABLE_INFLUENCE
    FOOD_TYPES
    ORE_TYPES
    BUILDABLE_CLASSES
    SPACE_STATION_MODULES
    SHIP_TYPES
    SHIP_TRADE_TYPES
    SHIP_WASTE_TYPES
    SHIP_SINGLE_USE_TYPES
);

our %EXPORT_TAGS = (
    all =>  [qw(
        GROWTH
        GROWTH_N
        GROWTH_S
        GROWTH_F
        INFLATION
        INFLATION_N
        INFLATION_S
        INFLATION_F
        CONSUME
        CONSUME_N
        CONSUME_S
        CONSUME_F
        WASTE
        WASTE_N
        WASTE_S
        WASTE_F
        HAPPY
        HAPPY_N
        HAPPY_S
        HAPPY_F
        TINFLATE
        TINFLATE_N
        TINFLATE_S
        TINFLATE_F
        SECONDS_IN_A_DAY
        MINIMUM_EXERTABLE_INFLUENCE
        FOOD_TYPES
        ORE_TYPES
        BUILDABLE_CLASSES
        SPACE_STATION_MODULES
        SHIP_TYPES
        SHIP_TRADE_TYPES
        SHIP_WASTE_TYPES
        SHIP_SINGLE_USE_TYPES
        )],
);

1;

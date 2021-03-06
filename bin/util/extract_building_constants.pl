use strict;
use lib ('/home/keno/ka-server/lib');
use Data::Dumper;
use KA::DB;
use KA;
use Getopt::Long;

our $quiet;
our $db = KA->db;
my $empire_id;
my $bid;
  GetOptions(
    'quiet'    => \$quiet,  
    'empire_id=s' => \$empire_id,
    'bid=s'   => \$bid,
  );

  my $empires = $db->resultset('Empire');
  my $empire = $empires->find($empire_id);
  die "Could not find Empire!\n" unless $empire;
  print "Setting up for empire: ".$empire->name." : ".$empire_id."\n";
  my $ehash;
  my $body;
  if ($bid) {
      $body = $db->resultset('Map::Body')->find($bid);
  }
  else {
      $body = $db->resultset('Map::Body')->find($empire->home_planet_id);
  }

print "Building, lvl, food_hour, ore_hour, water_hour, energy_hour, waste_hour, happiness_hour, food_capacity, ore_capacity, water_capacity, energy_capacity, waste_capacity, food cost, ore cost, water cost, energy cost, waste cost, time cost\n";

for my $building (qw(
    KA::DB::Result::Building::Shipyard
    KA::DB::Result::Building::SpacePort
    KA::DB::Result::Building::Intelligence
    KA::DB::Result::Building::IntelTraining
    KA::DB::Result::Building::MayhemTraining
    KA::DB::Result::Building::PoliticsTraining
    KA::DB::Result::Building::TheftTraining
    KA::DB::Result::Building::Security
    KA::DB::Result::Building::Trade
    KA::DB::Result::Building::Transporter
    KA::DB::Result::Building::Archaeology
    KA::DB::Result::Building::DistributionCenter
    KA::DB::Result::Building::SAW
    KA::DB::Result::Building::Water::AtmosphericEvaporator
    KA::DB::Result::Building::Permanent::GreatBallOfJunk
    KA::DB::Result::Building::Permanent::JunkHengeSculpture
    KA::DB::Result::Building::Permanent::MetalJunkArches
    KA::DB::Result::Building::Permanent::PyramidJunkSculpture
    KA::DB::Result::Building::Permanent::SpaceJunkPark
    KA::DB::Result::Building::ThemePark
    KA::DB::Result::Building::Permanent::BlackHoleGenerator
    KA::DB::Result::Building::Permanent::TheDillonForge
    KA::DB::Result::Building::Permanent::HallsOfVrbansk
    KA::DB::Result::Building::Permanent::GratchsGauntlet
    KA::DB::Result::Building::Permanent::KasternsKeep
    KA::DB::Result::Building::SubspaceSupplyDepot
    KA::DB::Result::Building::SupplyPod
    KA::DB::Result::Building::Permanent::PantheonOfHagness
    KA::DB::Result::Building::Capitol
    KA::DB::Result::Building::Stockpile
    KA::DB::Result::Building::Food::Algae
    KA::DB::Result::Building::Food::Apple
    KA::DB::Result::Building::Food::Bean
    KA::DB::Result::Building::Food::Beeldeban
    KA::DB::Result::Building::Food::Bread
    KA::DB::Result::Building::Food::Burger
    KA::DB::Result::Building::Food::Cheese
    KA::DB::Result::Building::Food::Chip
    KA::DB::Result::Building::Food::Cider
    KA::DB::Result::Building::Food::Corn
    KA::DB::Result::Building::Food::CornMeal
    KA::DB::Result::Building::Permanent::EssentiaVein
    KA::DB::Result::Building::Permanent::Volcano
    KA::DB::Result::Building::Permanent::MassadsHenge
    KA::DB::Result::Building::Permanent::LibraryOfJith
    KA::DB::Result::Building::Permanent::NaturalSpring
    KA::DB::Result::Building::Permanent::OracleOfAnid
    KA::DB::Result::Building::Permanent::TempleOfTheDrajilites
    KA::DB::Result::Building::Permanent::GeoThermalVent
    KA::DB::Result::Building::Permanent::InterDimensionalRift
    KA::DB::Result::Building::Permanent::CitadelOfKnope
    KA::DB::Result::Building::Permanent::CrashedShipSite
    KA::DB::Result::Building::Permanent::KalavianRuins
    KA::DB::Result::Building::Permanent::Grove
    KA::DB::Result::Building::Permanent::Sand
    KA::DB::Result::Building::Permanent::Lagoon
    KA::DB::Result::Building::Permanent::Crater
    KA::DB::Result::Building::Food::Dairy
    KA::DB::Result::Building::Permanent::DentonBrambles
    KA::DB::Result::Building::Development
    KA::DB::Result::Building::Embassy
    KA::DB::Result::Building::Energy::Reserve
    KA::DB::Result::Building::EntertainmentDistrict
    KA::DB::Result::Building::Espionage
    KA::DB::Result::Building::Energy::Fission
    KA::DB::Result::Building::Food::Reserve
    KA::DB::Result::Building::Energy::Fusion
    KA::DB::Result::Building::DeployedBleeder
    KA::DB::Result::Building::GasGiantLab
    KA::DB::Result::Building::Permanent::GasGiantPlatform
    KA::DB::Result::Building::Energy::Geo
    KA::DB::Result::Building::Energy::Hydrocarbon
    KA::DB::Result::Building::Food::Lapis
    KA::DB::Result::Building::Food::Malcud
    KA::DB::Result::Building::Ore::Mine
    KA::DB::Result::Building::Ore::Ministry
    KA::DB::Result::Building::Network19
    KA::DB::Result::Building::Observatory
    KA::DB::Result::Building::Ore::Refinery
    KA::DB::Result::Building::Ore::Storage
    KA::DB::Result::Building::Food::Pancake
    KA::DB::Result::Building::Park
    KA::DB::Result::Building::Food::Pie
    KA::DB::Result::Building::PlanetaryCommand
    KA::DB::Result::Building::Food::Potato
    KA::DB::Result::Building::Propulsion
    KA::DB::Result::Building::Oversight
    KA::DB::Result::Building::Permanent::RockyOutcrop
    KA::DB::Result::Building::Permanent::Lake
    KA::DB::Result::Building::Food::Shake
    KA::DB::Result::Building::Energy::Singularity
    KA::DB::Result::Building::Food::Soup
    KA::DB::Result::Building::Food::Syrup
    KA::DB::Result::Building::TerraformingLab
    KA::DB::Result::Building::GeneticsLab
    KA::DB::Result::Building::Permanent::TerraformingPlatform
    KA::DB::Result::Building::University
    KA::DB::Result::Building::Energy::Waste
    KA::DB::Result::Building::Waste::Exchanger
    KA::DB::Result::Building::Waste::Recycling
    KA::DB::Result::Building::Waste::Sequestration
    KA::DB::Result::Building::Waste::Digester
    KA::DB::Result::Building::Waste::Treatment
    KA::DB::Result::Building::Water::Production
    KA::DB::Result::Building::Water::Purification
    KA::DB::Result::Building::Water::Reclamation
    KA::DB::Result::Building::Water::Storage
    KA::DB::Result::Building::Food::Wheat
    KA::DB::Result::Building::Permanent::Beach1
    KA::DB::Result::Building::Permanent::Beach2
    KA::DB::Result::Building::Permanent::Beach3
    KA::DB::Result::Building::Permanent::Beach4
    KA::DB::Result::Building::Permanent::Beach5
    KA::DB::Result::Building::Permanent::Beach6
    KA::DB::Result::Building::Permanent::Beach7
    KA::DB::Result::Building::Permanent::Beach8
    KA::DB::Result::Building::Permanent::Beach9
    KA::DB::Result::Building::Permanent::Beach10
    KA::DB::Result::Building::Permanent::Beach11
    KA::DB::Result::Building::Permanent::Beach12
    KA::DB::Result::Building::Permanent::Beach13
    KA::DB::Result::Building::PilotTraining
    KA::DB::Result::Building::MissionCommand
    KA::DB::Result::Building::CloakingLab
    KA::DB::Result::Building::MunitionsLab
    KA::DB::Result::Building::LuxuryHousing
    KA::DB::Result::Building::Permanent::Fissure
    KA::DB::Result::Building::Permanent::Ravine
    KA::DB::Result::Building::Permanent::AlgaePond
    KA::DB::Result::Building::Permanent::LapisForest
    KA::DB::Result::Building::Permanent::BeeldebanNest
    KA::DB::Result::Building::Permanent::MalcudField
    KA::DB::Result::Building::SSLa
    KA::DB::Result::Building::SSLb
    KA::DB::Result::Building::SSLc
    KA::DB::Result::Building::SSLd
    KA::DB::Result::Building::Permanent::AmalgusMeadow
    KA::DB::Result::Building::Permanent::DentonBrambles
    KA::DB::Result::Building::MercenariesGuild
    KA::DB::Result::Building::Module::StationCommand
    KA::DB::Result::Building::Module::OperaHouse
    KA::DB::Result::Building::Module::ArtMuseum
    KA::DB::Result::Building::Module::CulinaryInstitute
    KA::DB::Result::Building::Module::IBS
    KA::DB::Result::Building::Module::Warehouse
    KA::DB::Result::Building::Module::Parliament
    KA::DB::Result::Building::Module::PoliceStation
    KA::DB::Result::Building::LCOTa
    KA::DB::Result::Building::LCOTb
    KA::DB::Result::Building::LCOTc
    KA::DB::Result::Building::LCOTd
    KA::DB::Result::Building::LCOTe
    KA::DB::Result::Building::LCOTf
    KA::DB::Result::Building::LCOTg
    KA::DB::Result::Building::LCOTh
    KA::DB::Result::Building::LCOTi
    )) {
    my $lvl = 1;
    for my $lvl (1..30) {
      my $obj = KA->db->resultset('Building')->new({
          body_id  => $bid,
          class    => $building,
          level    => $lvl,
          body     => $body,
        });
      my $cost = $obj->cost_to_upgrade;
      print join(",", $obj->name, $lvl,
                      $obj->food_hour,
                      $obj->ore_hour,
                      $obj->water_hour,
                      $obj->energy_hour,
                      $obj->waste_hour,
                      $obj->happiness_hour,
                      $obj->food_capacity,
                      $obj->ore_capacity,
                      $obj->water_capacity,
                      $obj->energy_capacity,
                      $obj->waste_capacity,
                      $cost->{food},
                      $cost->{ore},
                      $cost->{water},
                      $cost->{energy},
                      $cost->{waste},
                      $cost->{time},
                ),"\n";
     }

}

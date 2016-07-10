package KA::DB::Result::Ships::SupplyPod3;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Ships';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::PlanetaryCommand',  level => 20 } ];
use constant base_food_cost         => 480000;
use constant base_water_cost        => 500000;
use constant base_energy_cost       => 1200000;
use constant base_ore_cost          => 1200000;
use constant base_time_cost         => 60 * 60 * 6; 
use constant base_waste_cost        => 450000;
use constant base_speed             => 1500;
use constant base_stealth           => 0;
use constant base_hold_size         => 2000;
use constant pilotable              => 0;
use constant build_tags             => [qw(Colonization)];
use constant image_subdir => 'v2';
use constant supply_pod_level       => 15;
use constant type_formatted         => 'Supply Pod III';

with "KA::Role::Ship::Send::Planet";
with "KA::Role::Ship::Send::Inhabited";
with "KA::Role::Ship::Send::LoadSupplyPod";
with "KA::Role::Ship::Arrive::DeploySupplyPod";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

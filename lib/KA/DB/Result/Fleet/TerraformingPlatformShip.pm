package KA::DB::Result::Fleet::TerraformingPlatformShip;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::TerraformingLab',  level => 1 } ];
use constant base_food_cost         => 96000;
use constant base_water_cost        => 180000;
use constant base_energy_cost       => 310000;
use constant base_ore_cost          => 226000;
use constant base_time_cost         => 45000;
use constant base_waste_cost        => 45000;
use constant base_speed             => 550;
use constant base_stealth           => 0;
use constant base_hold_size         => 0;
use constant pilotable              => 1;
use constant build_tags             => ['Colonization'];

with "KA::Role::Fleet::Send::Planet";
with "KA::Role::Fleet::Arrive::AddTerraformingPlatform";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

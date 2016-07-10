package KA::DB::Result::Ships::Excavator;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Ships';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Archaeology',  level => 11 } ];
use constant base_food_cost         => 3000;
use constant base_water_cost        => 5000;
use constant base_energy_cost       => 20000;
use constant base_ore_cost          => 80000;
use constant base_time_cost         => 8 * 60 * 60;
use constant base_waste_cost        => 10000;
use constant base_speed             => 1000;
use constant base_stealth           => 0;
use constant base_hold_size         => 0;
use constant build_tags             => ['Exploration'];

with "KA::Role::Ship::Send::AsteroidAndUninhabited";
with "KA::Role::Ship::Arrive::TriggerDefense";
with "KA::Role::Ship::Arrive::DeployExcavator";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

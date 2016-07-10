package KA::DB::Result::Fleet::ColonyShip;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Observatory',  level => 5 } ];
use constant base_food_cost         => 45000;
use constant base_water_cost        => 45000;
use constant base_energy_cost       => 45000;
use constant base_ore_cost          => 45000;
use constant base_time_cost         => 60 * 60 * 24;
use constant base_waste_cost        => 10000;
use constant base_combat            => 1000;
use constant base_speed             => 455;
use constant base_stealth           => 0;
use constant base_hold_size         => 0;
use constant pilotable              => 1;
use constant build_tags             => ['Colonization'];

with "KA::Role::Fleet::Send::Planet";
with "KA::Role::Fleet::Send::Uninhabited";
with "KA::Role::Fleet::Send::SpendNextColonyCost";
with "KA::Role::Fleet::Send::IsHostile";
with "KA::Role::Fleet::Arrive::TriggerDefense";
with "KA::Role::Fleet::Arrive::Colonize";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

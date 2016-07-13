package KA::DB::Result::Fleet::Thud;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::MunitionsLab',  level => 3 } ];
use constant base_food_cost         => 7000;
use constant base_water_cost        => 8000;
use constant base_energy_cost       => 23000;
use constant base_ore_cost          => 45000;
use constant base_time_cost         => 60 * 60 * 2;
use constant base_waste_cost        => 8400;
use constant base_speed             => 700;
use constant base_stealth           => 1600;
use constant base_combat            => 2100;
use constant base_hold_size         => 0;
use constant build_tags             => ['War'];

with "KA::Role::Fleet::Send::Planet";
with "KA::Role::Fleet::Send::Inhabited";
with "KA::Role::Fleet::Send::NotIsolationist";
with "KA::Role::Fleet::Send::IsHostile";
with "KA::Role::Fleet::Arrive::TriggerDefense";
with "KA::Role::Fleet::Arrive::DeploySmolderingCrater";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

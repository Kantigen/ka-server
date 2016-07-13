package KA::DB::Result::Fleet::Placebo5;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [{ class=> 'KA::DB::Result::Building::CloakingLab',  level => 25 }];
use constant base_food_cost         => 2000;
use constant base_water_cost        => 2000;
use constant base_energy_cost       => 8000;
use constant base_ore_cost          => 8000;
use constant base_time_cost         => 3600;
use constant base_waste_cost        => 800;
use constant base_speed             => 2500;
use constant base_combat            => 0;
use constant base_stealth           => 8500;
use constant base_hold_size         => 0;
use constant build_tags             => [qw(War)];
use constant type_formatted         => 'Placebo V';

with "KA::Role::Fleet::Send::Planet";
with "KA::Role::Fleet::Send::Inhabited";
with "KA::Role::Fleet::Send::NotIsolationist";
with "KA::Role::Fleet::Send::IsHostile";
with "KA::Role::Fleet::Arrive::Scuttle";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

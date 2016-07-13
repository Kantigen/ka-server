package KA::DB::Result::Fleet::SpyShuttle;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';
        
use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Espionage',  level => 15 } ];
use constant base_food_cost         => 750;
use constant base_water_cost        => 2300;
use constant base_energy_cost       => 15000;
use constant base_ore_cost          => 13000;
use constant base_time_cost         => 7200;
use constant base_waste_cost        => 5000;
use constant base_speed             => 2000;
use constant base_stealth           => 6200;
use constant base_hold_size         => 0;
use constant pilotable              => 1;
use constant build_tags             => ['Intelligence'];
use constant max_occupants          => 4;

with "KA::Role::Fleet::Send::Planet";
with "KA::Role::Fleet::Send::Inhabited";
with "KA::Role::Fleet::Send::NotIsolationist";
with "KA::Role::Fleet::Send::LoadWithSpies";
with "KA::Role::Fleet::Send::IsHostile";
with "KA::Role::Fleet::Arrive::CaptureWithSpies";
with "KA::Role::Fleet::Arrive::Orbit";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

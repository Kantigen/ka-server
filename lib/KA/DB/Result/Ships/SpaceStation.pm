package KA::DB::Result::Ships::SpaceStation;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Ships';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Embassy',  level => 20 } ];
use constant base_food_cost         => 8000000;
use constant base_water_cost        => 8000000;
use constant base_energy_cost       => 8000000;
use constant base_ore_cost          => 8000000;
use constant base_time_cost         => 60 * 60 * 72;
use constant base_waste_cost        => 1000000;
use constant base_speed             => 10;
use constant base_stealth           => 0;
use constant base_hold_size         => 0;
use constant pilotable              => 1;
use constant build_tags             => [qw(War Intelligence)];
use constant type_formatted         => 'Space Station Hull';

sub sitter_can_send() { 0 }

with "KA::Role::Ship::Send::Planet";
with 'KA::Role::Ship::Send::Uninhabited';
with "KA::Role::Ship::Send::StarterZone";
with 'KA::Role::Ship::Send::MemberOfAlliance';
with "KA::Role::Ship::Send::SpendNextColonyCost";
with "KA::Role::Ship::Send::IsHostile";
with "KA::Role::Ship::Arrive::ConvertToStation";
with "KA::Role::Ship::Arrive::TriggerDefense";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

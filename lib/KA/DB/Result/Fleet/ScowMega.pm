package KA::DB::Result::Fleet::ScowMega;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Waste::Sequestration',  level => 30 } ];
use constant base_food_cost         =>   60000;
use constant base_water_cost        =>  180000;
use constant base_energy_cost       => 6000000;
use constant base_ore_cost          => 1500000;
use constant base_time_cost         => 98000;
use constant base_waste_cost        => 25000000;
use constant base_speed             => 100;
use constant base_combat            => 0;
use constant base_stealth           => 0;
use constant base_hold_size         => 300000;
use constant base_berth_level       => 25;
use constant build_tags             => [qw(War WasteChain)];

with "KA::Role::Fleet::Send::PlanetAndStar";
with "KA::Role::Fleet::Send::MaybeHostile";
with "KA::Role::Fleet::Arrive::TriggerDefense";
with "KA::Role::Fleet::Arrive::DumpWaste";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

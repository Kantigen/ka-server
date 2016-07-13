package KA::DB::Result::Fleet::ScowLarge;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Waste::Sequestration',  level => 20 } ];
use constant base_food_cost         =>  10000;
use constant base_water_cost        =>  32000;
use constant base_energy_cost       => 170000;
use constant base_ore_cost          => 120000;
use constant base_time_cost         =>  32000;
use constant base_waste_cost        =>  50000;
use constant base_speed             => 325;
use constant base_combat            => 600;
use constant base_stealth           => 0;
use constant base_hold_size         => 12000;
use constant base_berth_level       => 15;
use constant build_tags             => [qw(War WasteChain)];

with "KA::Role::Fleet::Send::PlanetAndStar";
with "KA::Role::Fleet::Send::MaybeHostile";
with "KA::Role::Fleet::Arrive::TriggerDefense";
with "KA::Role::Fleet::Arrive::DumpWaste";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

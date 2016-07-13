package KA::DB::Result::Ships::ScowFast;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Ships';

use constant prereq                 => [{ class=> 'KA::DB::Result::Building::Waste::Sequestration',  level => 25 },
                                        { class=> 'KA::DB::Result::Building::Propulsion',  level => 25 } ];
use constant base_food_cost         => 3000;
use constant base_water_cost        => 10000;
use constant base_energy_cost       => 100000;
use constant base_ore_cost          => 60000;
use constant base_time_cost         => 21600;
use constant base_waste_cost        => 25000;
use constant base_speed             => 700;
use constant base_combat            => 500;
use constant base_stealth           => 0;
use constant base_hold_size         => 2000;
use constant base_berth_level        => 20;
use constant build_tags             => [qw(War WasteChain)];
use constant image_subdir => 'v2';

with "KA::Role::Ship::Send::NeutralArea";
with "KA::Role::Ship::Send::PlanetAndStar";
with "KA::Role::Ship::Send::MaybeHostile";
with "KA::Role::Ship::Arrive::TriggerDefense";
with "KA::Role::Ship::Arrive::DumpWaste";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

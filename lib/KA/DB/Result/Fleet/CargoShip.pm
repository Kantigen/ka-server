package KA::DB::Result::Fleet::CargoShip;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Fleet';

use constant prereq                 => [ { class=> 'KA::DB::Result::Building::Trade',  level => 10 } ];
use constant base_food_cost         => 1200;
use constant base_water_cost        => 3600;
use constant base_energy_cost       => 12000;
use constant base_ore_cost          => 20400;
use constant base_time_cost         => 7200;
use constant base_waste_cost        => 1500;
use constant base_speed             => 1050;
use constant base_stealth           => 1500;
use constant base_hold_size         => 1700;
use constant base_berth_level       => 5;
use constant pilotable              => 1;
use constant build_tags             => [qw(Trade Mining Intelligence SupplyChain)];

with "KA::Role::Fleet::Send::UsePush";
with "KA::Role::Fleet::Arrive::CaptureWithSpies";
with "KA::Role::Fleet::Arrive::CargoExchange";
with "KA::Role::Fleet::Arrive::PickUpSpies";

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

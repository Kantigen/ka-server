package KA::DB::Result::Building::Module::OperaHouse;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Module';
with 'KA::Role::Influencer';

use constant controller_class => 'KA::RPC::Building::OperaHouse';
use constant image => 'operahouse';
use constant name => 'Opera House';
use constant max_instances_per_planet => 1;
use constant water_consumption => 160;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

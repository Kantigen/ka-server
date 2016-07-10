package KA::RPC::Building::WaterProduction;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/waterproduction';
}

sub model_class {
    return 'KA::DB::Result::Building::Water::Production';
}

no Moose;
__PACKAGE__->meta->make_immutable;


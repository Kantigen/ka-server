package KA::RPC::Building::OreRefinery;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/orerefinery';
}

sub model_class {
    return 'KA::DB::Result::Building::Ore::Refinery';
}

no Moose;
__PACKAGE__->meta->make_immutable;


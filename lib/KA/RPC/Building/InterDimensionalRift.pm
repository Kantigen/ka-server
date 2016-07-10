package KA::RPC::Building::InterDimensionalRift;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/interdimensionalrift';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::InterDimensionalRift';
}

no Moose;
__PACKAGE__->meta->make_immutable;


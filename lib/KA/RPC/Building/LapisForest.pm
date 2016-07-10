package KA::RPC::Building::LapisForest;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/lapisforest';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::LapisForest';
}

no Moose;
__PACKAGE__->meta->make_immutable;


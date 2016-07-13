package KA::RPC::Building::Ravine;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/ravine';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Ravine';
}

no Moose;
__PACKAGE__->meta->make_immutable;


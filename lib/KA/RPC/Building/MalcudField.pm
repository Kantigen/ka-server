package KA::RPC::Building::MalcudField;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/malcudfield';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::MalcudField';
}

no Moose;
__PACKAGE__->meta->make_immutable;


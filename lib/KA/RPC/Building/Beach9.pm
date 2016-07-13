package KA::RPC::Building::Beach9;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/beach9';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Beach9';
}

no Moose;
__PACKAGE__->meta->make_immutable;


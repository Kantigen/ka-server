package KA::RPC::Building::Lake;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/lake';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Lake';
}

no Moose;
__PACKAGE__->meta->make_immutable;


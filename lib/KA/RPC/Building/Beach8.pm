package KA::RPC::Building::Beach8;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/beach8';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Beach8';
}

no Moose;
__PACKAGE__->meta->make_immutable;


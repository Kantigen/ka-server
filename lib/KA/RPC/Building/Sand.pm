package KA::RPC::Building::Sand;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/sand';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Sand';
}

no Moose;
__PACKAGE__->meta->make_immutable;


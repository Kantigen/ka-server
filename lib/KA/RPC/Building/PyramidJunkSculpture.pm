package KA::RPC::Building::PyramidJunkSculpture;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/pyramidjunksculpture';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::PyramidJunkSculpture';
}

no Moose;
__PACKAGE__->meta->make_immutable;


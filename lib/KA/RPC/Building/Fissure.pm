package KA::RPC::Building::Fissure;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/fissure';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Fissure';
}

no Moose;
__PACKAGE__->meta->make_immutable;


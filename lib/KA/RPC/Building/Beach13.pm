package KA::RPC::Building::Beach13;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/beach13';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Beach13';
}

no Moose;
__PACKAGE__->meta->make_immutable;


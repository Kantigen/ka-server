package KA::RPC::Building::SpaceJunkPark;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/spacejunkpark';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::SpaceJunkPark';
}

no Moose;
__PACKAGE__->meta->make_immutable;


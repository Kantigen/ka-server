package KA::RPC::Building::AmalgusMeadow;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/amalgusmeadow';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::AmalgusMeadow';
}

no Moose;
__PACKAGE__->meta->make_immutable;

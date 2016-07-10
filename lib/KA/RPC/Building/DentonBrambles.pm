package KA::RPC::Building::DentonBrambles;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/dentonbrambles';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::DentonBrambles';
}

no Moose;
__PACKAGE__->meta->make_immutable;

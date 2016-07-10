package KA::RPC::Building::KasternsKeep;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/kasternskeep';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::KasternsKeep';
}

no Moose;
__PACKAGE__->meta->make_immutable;


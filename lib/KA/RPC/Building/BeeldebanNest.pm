package KA::RPC::Building::BeeldebanNest;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/beeldebannest';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::BeeldebanNest';
}

no Moose;
__PACKAGE__->meta->make_immutable;


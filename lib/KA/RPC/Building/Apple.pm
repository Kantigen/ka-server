package KA::RPC::Building::Apple;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/apple';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Apple';
}

no Moose;
__PACKAGE__->meta->make_immutable;


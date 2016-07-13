package KA::RPC::Building::Burger;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/burger';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Burger';
}

no Moose;
__PACKAGE__->meta->make_immutable;


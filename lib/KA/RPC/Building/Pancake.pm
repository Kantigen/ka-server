package KA::RPC::Building::Pancake;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/pancake';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Pancake';
}

no Moose;
__PACKAGE__->meta->make_immutable;


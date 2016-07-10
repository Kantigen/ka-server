package KA::RPC::Building::Dairy;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/dairy';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Dairy';
}

no Moose;
__PACKAGE__->meta->make_immutable;


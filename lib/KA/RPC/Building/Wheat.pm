package KA::RPC::Building::Wheat;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/wheat';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Wheat';
}

no Moose;
__PACKAGE__->meta->make_immutable;


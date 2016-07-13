package KA::RPC::Building::Bread;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/bread';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Bread';
}

no Moose;
__PACKAGE__->meta->make_immutable;


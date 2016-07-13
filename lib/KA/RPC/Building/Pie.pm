package KA::RPC::Building::Pie;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/pie';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Pie';
}

no Moose;
__PACKAGE__->meta->make_immutable;


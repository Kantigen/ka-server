package KA::RPC::Building::Cider;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/cider';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Cider';
}

no Moose;
__PACKAGE__->meta->make_immutable;


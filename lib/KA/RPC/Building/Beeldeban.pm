package KA::RPC::Building::Beeldeban;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/beeldeban';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Beeldeban';
}

no Moose;
__PACKAGE__->meta->make_immutable;


package KA::RPC::Building::Syrup;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/syrup';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Syrup';
}

no Moose;
__PACKAGE__->meta->make_immutable;


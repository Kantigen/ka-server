package KA::RPC::Building::SupplyPod;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/supplypod';
}

sub model_class {
    return 'KA::DB::Result::Building::SupplyPod';
}

no Moose;
__PACKAGE__->meta->make_immutable;


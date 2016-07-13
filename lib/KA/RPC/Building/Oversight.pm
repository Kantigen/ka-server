package KA::RPC::Building::Oversight;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/oversight';
}

sub model_class {
    return 'KA::DB::Result::Building::Oversight';
}

no Moose;
__PACKAGE__->meta->make_immutable;


package KA::RPC::Building::Propulsion;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/propulsion';
}

sub model_class {
    return 'KA::DB::Result::Building::Propulsion';
}

no Moose;
__PACKAGE__->meta->make_immutable;


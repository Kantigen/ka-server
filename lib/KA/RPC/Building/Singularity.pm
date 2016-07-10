package KA::RPC::Building::Singularity;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/singularity';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Singularity';
}

no Moose;
__PACKAGE__->meta->make_immutable;


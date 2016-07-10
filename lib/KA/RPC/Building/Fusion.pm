package KA::RPC::Building::Fusion;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/fusion';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Fusion';
}

no Moose;
__PACKAGE__->meta->make_immutable;


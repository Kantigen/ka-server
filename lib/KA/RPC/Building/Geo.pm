package KA::RPC::Building::Geo;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/geo';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Geo';
}

no Moose;
__PACKAGE__->meta->make_immutable;


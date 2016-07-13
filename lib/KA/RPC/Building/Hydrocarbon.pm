package KA::RPC::Building::Hydrocarbon;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/hydrocarbon';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Hydrocarbon';
}

no Moose;
__PACKAGE__->meta->make_immutable;


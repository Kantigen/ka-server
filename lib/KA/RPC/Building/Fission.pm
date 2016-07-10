package KA::RPC::Building::Fission;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/fission';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Fission';
}

no Moose;
__PACKAGE__->meta->make_immutable;


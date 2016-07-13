package KA::RPC::Building::CloakingLab;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/cloakinglab';
}

sub model_class {
    return 'KA::DB::Result::Building::CloakingLab';
}

no Moose;
__PACKAGE__->meta->make_immutable;


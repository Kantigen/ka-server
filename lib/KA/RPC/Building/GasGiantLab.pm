package KA::RPC::Building::GasGiantLab;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/gasgiantlab';
}

sub model_class {
    return 'KA::DB::Result::Building::GasGiantLab';
}

no Moose;
__PACKAGE__->meta->make_immutable;


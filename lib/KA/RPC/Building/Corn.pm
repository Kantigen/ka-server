package KA::RPC::Building::Corn;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/corn';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Corn';
}

no Moose;
__PACKAGE__->meta->make_immutable;


package KA::RPC::Building::Denton;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/denton';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Root';
}

no Moose;
__PACKAGE__->meta->make_immutable;


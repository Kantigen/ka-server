package KA::RPC::Building::Soup;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/soup';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Soup';
}

no Moose;
__PACKAGE__->meta->make_immutable;


package KA::RPC::Building::Bean;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/bean';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Bean';
}

no Moose;
__PACKAGE__->meta->make_immutable;


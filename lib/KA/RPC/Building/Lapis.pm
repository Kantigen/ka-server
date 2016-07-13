package KA::RPC::Building::Lapis;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/lapis';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::Lapis';
}

no Moose;
__PACKAGE__->meta->make_immutable;


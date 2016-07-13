package KA::RPC::Building::CornMeal;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/cornmeal';
}

sub model_class {
    return 'KA::DB::Result::Building::Food::CornMeal';
}

no Moose;
__PACKAGE__->meta->make_immutable;


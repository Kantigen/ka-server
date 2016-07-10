package KA::RPC::Building::University;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/university';
}

sub model_class {
    return 'KA::DB::Result::Building::University';
}

no Moose;
__PACKAGE__->meta->make_immutable;


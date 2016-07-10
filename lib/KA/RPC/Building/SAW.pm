package KA::RPC::Building::SAW;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/saw';
}

sub model_class {
    return 'KA::DB::Result::Building::SAW';
}

no Moose;
__PACKAGE__->meta->make_immutable;


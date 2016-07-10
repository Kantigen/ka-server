package KA::RPC::Building::Espionage;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/espionage';
}

sub model_class {
    return 'KA::DB::Result::Building::Espionage';
}

no Moose;
__PACKAGE__->meta->make_immutable;


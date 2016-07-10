package KA::RPC::Building::AlgaePond;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/algaepond';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::AlgaePond';
}

no Moose;
__PACKAGE__->meta->make_immutable;


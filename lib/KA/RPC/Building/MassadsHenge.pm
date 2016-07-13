package KA::RPC::Building::MassadsHenge;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/massadshenge';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::MassadsHenge';
}

no Moose;
__PACKAGE__->meta->make_immutable;


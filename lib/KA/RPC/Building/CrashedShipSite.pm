package KA::RPC::Building::CrashedShipSite;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/crashedshipsite';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::CrashedShipSite';
}

no Moose;
__PACKAGE__->meta->make_immutable;


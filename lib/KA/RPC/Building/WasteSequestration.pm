package KA::RPC::Building::WasteSequestration;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/wastesequestration';
}

sub model_class {
    return 'KA::DB::Result::Building::Waste::Sequestration';
}

no Moose;
__PACKAGE__->meta->make_immutable;


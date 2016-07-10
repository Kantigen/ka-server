package KA::RPC::Building::WasteEnergy;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/wasteenergy';
}

sub model_class {
    return 'KA::DB::Result::Building::Energy::Waste';
}

no Moose;
__PACKAGE__->meta->make_immutable;


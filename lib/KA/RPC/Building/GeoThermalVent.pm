package KA::RPC::Building::GeoThermalVent;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/geothermalvent';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::GeoThermalVent';
}

no Moose;
__PACKAGE__->meta->make_immutable;


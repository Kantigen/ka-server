package KA::RPC::Building::WasteTreatment;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/wastetreatment';
}

sub model_class {
    return 'KA::DB::Result::Building::Waste::Treatment';
}

no Moose;
__PACKAGE__->meta->make_immutable;


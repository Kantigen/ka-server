package KA::RPC::Building::WaterReclamation;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/waterreclamation';
}

sub model_class {
    return 'KA::DB::Result::Building::Water::Reclamation';
}

no Moose;
__PACKAGE__->meta->make_immutable;


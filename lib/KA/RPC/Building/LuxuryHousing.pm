package KA::RPC::Building::LuxuryHousing;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/luxuryhousing';
}

sub model_class {
    return 'KA::DB::Result::Building::LuxuryHousing';
}

no Moose;
__PACKAGE__->meta->make_immutable;


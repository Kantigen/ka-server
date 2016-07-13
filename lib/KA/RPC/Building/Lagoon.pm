package KA::RPC::Building::Lagoon;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/lagoon';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::Lagoon';
}

no Moose;
__PACKAGE__->meta->make_immutable;


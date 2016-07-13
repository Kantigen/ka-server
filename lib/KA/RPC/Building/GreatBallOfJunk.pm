package KA::RPC::Building::GreatBallOfJunk;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/greatballofjunk';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::GreatBallOfJunk';
}

no Moose;
__PACKAGE__->meta->make_immutable;


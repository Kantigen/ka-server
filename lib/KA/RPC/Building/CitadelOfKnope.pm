package KA::RPC::Building::CitadelOfKnope;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/citadelofknope';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::CitadelOfKnope';
}

no Moose;
__PACKAGE__->meta->make_immutable;


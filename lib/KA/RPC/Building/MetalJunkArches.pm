package KA::RPC::Building::MetalJunkArches;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/metaljunkarches';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::MetalJunkArches';
}

no Moose;
__PACKAGE__->meta->make_immutable;


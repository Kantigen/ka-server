package KA::RPC::Building::KalavianRuins;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/kalavianruins';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::KalavianRuins';
}

no Moose;
__PACKAGE__->meta->make_immutable;


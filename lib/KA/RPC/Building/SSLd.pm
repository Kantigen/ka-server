package KA::RPC::Building::SSLd;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/ssld';
}

sub model_class {
    return 'KA::DB::Result::Building::SSLd';
}


__PACKAGE__->register_rpc_method_names(qw());


no Moose;
__PACKAGE__->meta->make_immutable;


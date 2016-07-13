package KA::RPC::Building::LCOTg;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/lcotg';
}

sub model_class {
    return 'KA::DB::Result::Building::LCOTg';
}



__PACKAGE__->register_rpc_method_names(qw());


no Moose;
__PACKAGE__->meta->make_immutable;


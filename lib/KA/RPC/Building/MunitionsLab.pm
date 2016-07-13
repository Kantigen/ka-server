package KA::RPC::Building::MunitionsLab;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/munitionslab';
}

sub model_class {
    return 'KA::DB::Result::Building::MunitionsLab';
}

no Moose;
__PACKAGE__->meta->make_immutable;


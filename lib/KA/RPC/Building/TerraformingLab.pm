package KA::RPC::Building::TerraformingLab;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/terraforminglab';
}

sub model_class {
    return 'KA::DB::Result::Building::TerraformingLab';
}

no Moose;
__PACKAGE__->meta->make_immutable;


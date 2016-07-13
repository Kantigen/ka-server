package KA::RPC::Building::TerraformingPlatform;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/terraformingplatform';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::TerraformingPlatform';
}

no Moose;
__PACKAGE__->meta->make_immutable;


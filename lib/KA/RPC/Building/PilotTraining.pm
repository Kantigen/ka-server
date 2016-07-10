package KA::RPC::Building::PilotTraining;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/pilottraining';
}

sub model_class {
    return 'KA::DB::Result::Building::PilotTraining';
}

no Moose;
__PACKAGE__->meta->make_immutable;


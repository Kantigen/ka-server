package KA::Role::Fleet::Send::GasGiant;

use strict;
use Moose::Role;

after can_send_to_target => sub {
    my ($self, $target) = @_;
    confess [1009, 'Can only be sent to gas giants.'] unless ($target->isa('KA::DB::Result::Map::Body::Planet::GasGiant'));
};

1;

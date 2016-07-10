package KA::Role::Ship::Send::Planet;

use strict;
use Moose::Role;

after can_send_to_target => sub {
    my ($self, $target) = @_;
    confess [1009, 'Can only be sent to planets.'] unless ($target->isa('KA::DB::Result::Map::Body::Planet'));
};

1;

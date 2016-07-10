package KA::Role::Ship::Send::AsteroidAndStar;

use strict;
use Moose::Role;

after can_send_to_target => sub {
    my ($self, $target) = @_;
    confess [1009, 'Can only be sent to asteroids and stars.'] unless ($target->isa('KA::DB::Result::Map::Body::Asteroid') || $target->isa('KA::DB::Result::Map::Star'));
};

1;

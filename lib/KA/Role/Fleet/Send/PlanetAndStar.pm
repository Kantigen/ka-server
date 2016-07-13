package KA::Role::Fleet::Send::PlanetAndStar;

use strict;
use Moose::Role;

after can_send_to_target => sub {
    my ($self, $target) = @_;
    confess [1009, 'Can only be sent to planets and stars.'] unless ($target->isa('KA::DB::Result::Map::Body::Planet') || $target->isa('KA::DB::Result::Map::Star'));
};

1;

package KA::Redis;

use MooseX::Singleton;
use namespace::autoclean;

has redis => (
    is          => 'rw',
    required    => 1,
    isa         => 'Redis',
    handles     => [qw(set get del expire incrby decrby)],
);

__PACKAGE__->meta->make_immutable;


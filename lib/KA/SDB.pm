package KA::SDB;

use MooseX::Singleton;
use namespace::autoclean;

has db => (
    is          => 'rw',
    required    => 1,
    isa         => 'KA::DB',
           #handles     => [qw(resultset)],
);

__PACKAGE__->meta->make_immutable;


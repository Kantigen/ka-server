package KA::SDB;

use MooseX::Singleton;
use namespace::autoclean;

has db => (
    is          => 'rw',
    required    => 1,
    isa         => 'KA::DB',
           #handles     => [qw(resultset)],
);

sub resultset {
    __PACKAGE__->instance->db->resultset(@_);
}

__PACKAGE__->meta->make_immutable;


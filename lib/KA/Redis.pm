package KA::Redis;

use MooseX::Singleton;
use namespace::autoclean;
use Redis;

has redis => (
    is          => 'rw',
    required    => 1,
    isa         => 'Redis',
    handles     => [qw(set get del expire incrby decrby)],
    default     => sub {
        my $config = KA->config;
        Redis->new(server => join(':', $config->get('redis/host'), $config->get('redis/port')));
    },
);

__PACKAGE__->meta->make_immutable;


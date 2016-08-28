package KA::SDB;

use MooseX::Singleton;
use namespace::autoclean;

has db => (
    is          => 'rw',
    required    => 1,
    isa         => 'KA::DB',
    #handles     => [qw(resultset)],
    default     => sub {
        my $config = KA->config;
        my $db = KA::DB->connect(
                         $config->get('db/dsn'),
                         $config->get('db/username'),
                         $config->get('db/password'),
                         {
                             mysql_enable_utf8 => 1,
                             AutoCommit        => 1,
                         }
                        );

    }
);

__PACKAGE__->meta->make_immutable;


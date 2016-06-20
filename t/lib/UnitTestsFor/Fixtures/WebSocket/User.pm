package UnitTestsFor::Fixtures::WebSocket::User;

use Moose;
extends 'DBIx::Class::EasyFixture';
use namespace::autoclean;

my %definitions = (
    user_alfred => {
        new => 'User',
        using => {
            id                  => 1,
            username	        => 'alfred',
            password            => '{SSHA}KnIrp466EYjf16NptDR9bnhjCI5z6D14', # this is encrypted 'secret'
            email               => 'bert@example.com',
            registration_stage  => 'complete',
        },
    },
    user_bernard => {
        new => 'User',
        using => {
            id                  => 2,
            username	        => 'bernard',
            password            => '{SSHA}KnIrp466EYjf16NptDR9bnhjCI5z6D14', # this is encrypted 'secret'
            email               => 'alf@example.com',
            registration_stage  => 'enterEmailCode',
        },
    },

    user_charles => {
        new => 'User',
        using => {
            id                  => 3,
            username	        => 'charles',
            password            => '{SSHA}KnIrp466EYjf16NptDR9bnhjCI5z6D14', # this is encrypted 'secret'
            email               => 'bernie@example.com',
            registration_stage  => 'enterNewPassword',
        },
    },

);

sub get_definition {
    my ($self, $name) = @_;

    return $definitions{$name};
}

sub all_fixture_names { return keys %definitions };

__PACKAGE__->meta->make_immutable;
1;


package UnitTestsFor::KA::Email;

use KA::Email;

use Test::Class::Moose;

sub test_that_something_happens {
    my ($self) = @_;

    KA::Email->send_email({
        template => 'test',
        to       => 'me@1vasari.xyz',
        subject  => 'Testing Email',
        params   => [
            'Hello there!'
        ]
    });
    ok(1);
}

1;

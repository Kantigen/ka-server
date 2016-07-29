package UnitTestsFor::KA::PubSub;

use lib "lib";

use Test::Class::Moose;
use Data::Dumper;

use KA::PubSub;

sub test_construction {
    my ($self) = @_;

    my $pubsub = KA::PubSub->instance;

    isa_ok($pubsub, 'KA::PubSub');

}

1;


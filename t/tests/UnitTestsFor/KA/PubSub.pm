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

sub test_publish {
    my ($self) = @_;

    my $pubsub = KA::PubSub->instance;

    my $pipe = $pubsub->subscribe('test_channel');
    my $pipe2 = $pubsub->subscribe('test_channel');

    $pubsub->publish('test_channel', {
        hello   => 'world',
    });

    my $pipe3 = $pubsub->subscribe('test_next');    
    $pubsub->publish('test_next', {
        hello   => 'galaxy',
    });

    $pubsub->unsubscribe($pipe2);
    $pubsub->publish('test_channel', {
        hello   => 'universe',
    });



    ok(1);
}


1;


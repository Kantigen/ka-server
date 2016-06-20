package UnitTestsFor::KA::ClientCode;

use lib "lib";

use Test::Class::Moose;


use KA::WebSocket;

sub test_construction {
    my ($self) = @_;

    ok(1);
}

1;
__DATA__
# config-file-type: JSON 1
{   
    "foo" : {
        "bar" : "baz"
    }
}


package UnitTestsFor::KA::Config;

use lib "lib";

use Test::Class::Moose;
use File::Temp qw(tempfile);
use Data::Dumper;

use KA::Config;

sub test_construction_foo {
    my ($self) = @_;

    my $config = KA::Config->instance;

    isa_ok($config, 'KA::Config');

    is($config->get('test/foo'), 'bar', "Can get from config");
}

1;


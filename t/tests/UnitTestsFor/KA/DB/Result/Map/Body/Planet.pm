package UnitTestsFor::KA::DB::Result::Map::Body::Planet;

use lib "lib";
use lib "t/lib";

use Test::Class::Moose;
use Data::Dumper;
use Log::Log4perl;

use KA::DB::Result::Map::Body::Planet;

use UnitTestsFor::Fixtures::DB::Result::Map::Body::Planet;

sub test_construction {
    my ($self) = @_;

    my $ws_user = KA::DB::Result::Map::Body::Planet->new;
    isa_ok($ws_user, 'KA::DB::Result::Map::Body');
}

sub test_foo {
    my ($self) = @_;

    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::DB::Result::Map::Body::Planet->new( { schema => $db } );
    $fixtures->load('my_planet');

    my $planet = $db->resultset('Map::Body::Planet')->find(1);
    diag($planet);

    my $resource = $planet->get_resource('foo');

    diag("RESOURCE=".$resource);

    $planet->add_stored('foo', 1001);
    $planet->update_resources;

    my ($new_resource) = $db->resultset('Resource')->search;

    diag(Dumper($resource->{_column_data}));

    my $new_planet = $db->resultset('Map::Body::Planet')->find(1);
    diag(Dumper($new_planet->get_resource('foo')->{_column_data}));

    my $foo = $new_planet->get_resource('foo');
    is($foo->stored, 1001, "Stored");

    $new_planet->add_stored('foo', 20);
    is($foo->stored, 1021, "Stored new");

}


1;


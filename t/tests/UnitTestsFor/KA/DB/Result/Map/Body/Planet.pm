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

sub foo {
    my ($self) = @_;

    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('my_planet');
}


1;


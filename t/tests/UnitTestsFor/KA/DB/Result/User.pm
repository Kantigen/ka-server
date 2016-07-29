package UnitTestsFor::KA::DB::Result::User;

use lib "lib";
use lib "t/lib";

use Test::Class::Moose;
use Data::Dumper;
use Log::Log4perl;

use UnitTestsFor::Fixtures::DB::Result::Map::Body::Planet;

sub test_foo {
    my ($self) = @_;

    my $db = KA::SDB->db;
    my $user = $db->resultset('User')->create({
        id          => 1,
        username    => 'icydee',
        password    => 'secret',
    });
    diag("Password [".$user->password."]");

}


1;


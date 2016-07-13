use strict;
use 5.010;
use lib '../lib';
use KA::DB;
use KA;

my $stars = KA->db->resultset('KA::DB::Result::Map::Star');
my $bodies = KA->db->resultset('KA::DB::Result::Map::Body');
for (my $y = 15; $y > -15; $y--) {
    foreach (my $x = 15; $x > -15; $x--) {
        my $star = $stars->search({x=>$x, y=>$y})->count;
        my $body = $bodies->search({x=>$x, y=>$y})->first;
        if ($star) {
            print "*";
        }
        elsif (! defined $body) {
            print " ";
        }
        elsif ($body->isa('KA::DB::Result::Map::Body::Asteroid')) {
            print ".";
        }
        elsif ($body->isa('KA::DB::Result::Map::Body::Planet::GasGiant')) {
            print "O";
        }
        elsif ($body->isa('KA::DB::Result::Map::Body::Planet')) {
            print "o";
        }
        print " "; # y's are double tall to x's width
    }
    print "\n";
}


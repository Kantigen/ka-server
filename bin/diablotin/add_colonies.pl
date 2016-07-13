use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(randint format_date);
use Getopt::Long;
use List::MoreUtils qw(uniq);
use Module::Find;
$|=1;
our $quiet;
our $add_one;
GetOptions(
    'quiet'         => \$quiet,
    addone          => \$add_one,
);

out('Started');
my $start = time;

out('Loading DB');
our $db = KA->db;
my $config = KA->config;
my $empires = $db->resultset('KA::DB::Result::Empire');
my $ai = KA::AI::Diablotin->new;
my $viable_colonies = $db->resultset('KA::DB::Result::Map::Body')->search(
                { empire_id => undef, orbit => 7, size => { between => [45,49]}},
                { rows => 1, order_by => 'rand()' }
                );
my $lec = $empires->find(1);
my $diablotin = $empires->find(-7);
unless (defined $diablotin) {
    $diablotin = $ai->create_empire();
}


$ai->add_colonies($add_one);

my $finish = time;
out('Finished');
out((($finish - $start)/60)." minutes have elapsed");

###############
## SUBROUTINES
###############

sub out {
    my $message = shift;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}



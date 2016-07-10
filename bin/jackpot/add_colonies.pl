use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(format_date);
use Getopt::Long;

$|=1;
our $quiet;
our $add_one;
GetOptions(
    quiet           => \$quiet,
#    addone          => \$add_one,
);


out('Started');
my $start = time;
out('Loading DB');
our $db = KA->db;
my $config = KA->config;
my $empires = $db->resultset('KA::DB::Result::Empire');
my $ai = KA::AI::Jackpot->new;
my $viable_colonies = $db->resultset('KA::DB::Result::Map::Body')->search(
                { zone => '0|0', empire_id => undef, size => { between => [40,60]},
                  x => { between => [-50,50]}, y => {between => [-50,50]}},
                { rows => 1, order_by => 'rand()' }
                );
my $jackpot = $empires->find(-4);
unless (defined $jackpot) {
    out('Creating new empire');
    $jackpot = $ai->create_empire();
}

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



use 5.010;
use strict;
use feature "switch";
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(randint format_date);
use Getopt::Long;
use DateTime;
$|=1;
our $quiet;
our $trade_num = 6;
GetOptions(
    'quiet' => \$quiet,  
    'tnum'  => \$trade_num,
);

out('Started');
my $start = time;

out('Loading DB');
our $db = KA->db;
my $now = DateTime->now;

my $empire = 
my $body_id   = home world
out('Checking for existing trades from LCE');

my $trades = $db->resultset('Market')->search({
  body_id => $body_id,
});


my $trades_needed = $trade_num - $trades->count;

if ($trades_needed < 1) {
    out('No Trades Needed');
}
else {
    out('Add enough smugglers to carry new trades');
    my @ships = $db->result('Ships')->search({
    });
    my $ships_needed = $trades_needed - scalar @ships;
    for (1..$ships_needed) {
    }
    out('Adding '.$trades_needed.' Trades.');
    for (1..$trades_needed) {
    }
}

my $finish = time;
out('Finished');
out((($finish - $start)/60)." minutes have elapsed");


###############
## SUBROUTINES
###############

sub out {
    my ($message) = @_;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}


use 5.010;
use strict;
use feature "switch";
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use List::Util qw(shuffle);
use KA::Util qw(randint format_date);
use Getopt::Long;
$|=1;
our $quiet;
GetOptions(
    'quiet'         => \$quiet,  
);


out('Started');
my $start = time;
my $date_ended = DateTime->now->subtract( days => 30 );

out('Loading DB');
our $db = KA->db;
our $dtf = $db->storage->datetime_parser;

out('Deleting Old Battle Logs');
my $log = $db->resultset('Log::Battles');
$log->search({ date_stamp => { '<' => $dtf->format_datetime($date_ended) }})->delete_all;

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



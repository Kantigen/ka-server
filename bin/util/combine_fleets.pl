use 5.010;
use strict;
use feature "switch";
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(randint format_date);
use Getopt::Long;
$|=1;
our $quiet;
GetOptions(
    'quiet'         => \$quiet,  
);

out('Started');
my $start = time;

out('Loading DB');
our $db = KA->db;

out('Touch all fleets');
my $fleets = $db->resultset('Fleet')->search;

while (my $fleet = $fleets->next) {
    eval {
        out("Update fleet [".$fleet->mark."]");
        $fleet->mark('one');
        $fleet->update;
    };    
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


use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(randint format_date);
use KA::AI::DeLambert;

use Getopt::Long;
use List::MoreUtils qw(uniq);
use utf8;
$|=1;
our $quiet;
our $all;
GetOptions(
    'quiet'      => \$quiet,  
    'all'        => \$all,
);



out('Started');
my $start = time;

out('Loading DB');
our $db = KA->db;
my $empires = KA->db->resultset('KA::DB::Result::Empire')->search({
});

out('getting empires...');
my $de_lambert = KA::AI::DeLambert->new;

out('Sending introduction');

if (not $all) {
    $empires = $empires->search({name => ['icd','icydee','Sweden','Norway']});
}

$empires = $empires->search({id => {'>' => 1}});

while (my $empire = $empires->next) {
    out("Emailing ".$empire->name);
    $de_lambert->special_offer_email($empire);
}


my $finish = time;
out('Finished');
out((int(100*($finish - $start)/60)/100)." minutes have elapsed");




###############
## SUBROUTINES
###############




sub out {
    my $message = shift;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}



use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA::DB::Result::Spy;
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

out('Ticking spies');
KA::DB::Result::Spy->tick_all_spies($quiet ? 0 : 1);

#my $spies = $db->resultset('Spy')->search({
#    task    => {'!=' => 'Idle'},
#});
#my @ids = $spies->get_column('id')->all;
#foreach my $id (@ids) {
#    my $spy = $spies->find($id);
#    out('Ticking '.$spy->name);
#    my $starting_task = $spy->task;
#    $spy->is_available;
#    if ($spy->task eq 'Idle' && $starting_task ne 'Idle') {
#        if (!$spy->empire->skip_spy_recovery) {
#            $spy->empire->send_predefined_message(
#                tags        => ['Intelligence'],
#                filename    => 'ready_for_assignment.txt',
#                params      => [$spy->name, $spy->from_body->id, $spy->from_body->name],
#            );
#        }
#    }
#}

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



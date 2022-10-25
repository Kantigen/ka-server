
use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;

out('Loading DB...');

our $db = KA->db;
our $schedules = $db->resultset('Schedule')->search();

while (my $schedule = $schedules->next) {
  $schedule->queue_for_delivery();
}

sub out {
  say shift;
}

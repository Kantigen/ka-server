use strict;
use 5.010;
use lib '/home/keno/ka-server/lib';
use KA;

$|=1;

our $db = KA->db;

my $oracles = $db->resultset('Building')->search({
    class   => 'Building::Permanent::OracleOfAnid',
});
while (my $oracle = $oracles->next) {
    $oracle->recalc_probes;
}


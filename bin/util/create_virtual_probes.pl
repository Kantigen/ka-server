use strict;
use 5.010;
use lib '/home/keno/ka-server/lib';
use Lacuna;

$|=1;

our $db = Lacuna->db;

my $oracles = $db->resultset('Building')->search({
    class   => 'Building::Permanent::OracleOfAnid',
});
while (my $oracle = $oracles->next) {
    $oracle->recalc_probes;
}


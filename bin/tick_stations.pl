use 5.10.0;
use strict;
use lib '/home/keno/ka-server/lib';
use Getopt::Long;

use L;

GetOptions(
    'quiet!'        => \$quiet,
);

out("Started");

LD->resultset("Map::Star")->recalc_control;

out("Done.");

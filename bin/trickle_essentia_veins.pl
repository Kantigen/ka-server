use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(format_date);
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

trickle();


my $finish = time;
out('Finished');
out((($finish - $start)/60)." minutes have elapsed");


###############
## SUBROUTINES
###############


sub trickle {
    # find all empires, with the count of eveins they have, as a single call.
    # unowned eveins will naturally be ignored by the way the join is created
    # since we're just looking for empires that have eveins, not eveins in
    # general.
    my $empires = $db->resultset('Empire')
        ->search(
                 {
                     '_buildings.class' => "KA::DB::Result::Building::Permanent::EssentiaVein",
                 }, {
                     join => { 'bodies' => '_buildings' },
                     group_by => 'me.id',
                     '+select' => { count => '_buildings.id', -as => 'eveins' },
                 });

    while (my $empire = $empires->next)
    {
        my $eveins = $empire->get_column('eveins');
        out($empire->name . " x$eveins");
        $empire->add_essentia({
                     amount => 4 * $eveins,
                     reason => "Essentia Vein ($eveins)",
                 });
        $empire->update;
    }
}

# UTILITIES

sub out {
    my $message = shift;
    unless ($quiet) {
        say format_date(DateTime->now), " ", $message;
    }
}



use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use KA::DB;
use KA;
use KA::Util qw(randint format_date);
use Getopt::Long;
use KA::Constants qw(ORE_TYPES);
$|=1;
our $quiet;
GetOptions(
    'quiet'         => \$quiet,  
);


out('Started');
my $start = time;

out('Loading DB');
our $db = KA->db;
my $empires = $db->resultset('KA::DB::Result::Empire');
my $lec = $empires->find(1);

my $message = q{I hope this message finds you well in the new year. In our short time together we have learned much from each other. I have one more thing to teach you about our culture.

It is our tradition to celebrate the new year by giving gifts to those we consider friends. I have learned recently that you like antiques, and especially ancient carvings. Our miners have found many through-out the years, and though some in our socitety treasure them as you do, most consider them novelties. Therefore your planet would make a better home for them.

One of our freighters should be arriving momentarily to drop off 11 artifacts to your capitol planet. Please accept my gift, and I look forward to our continued trading relationship in the new year.

Your Trading Partner,

Tou Re Ell

KA Expanse Corp};

out('Giving Glyphs');
my @types = ORE_TYPES;
while (my $empire = $empires->next) {
    my $home = $empire->home_planet;
    next unless defined $home;
    out('Sending message...');
    $empire->send_message(
        tag         => 'Correspondence',
        subject     => 'Happy New Year',
        from        => $lec,
        body        => $message,
    );
    foreach (1..11) {
        my $type = $types[ rand @types ];
        say "Adding $type to ".$home->name;
        $home->add_glyph($type);
    }
    
}

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



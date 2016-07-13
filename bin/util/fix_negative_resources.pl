use strict;
use lib '/home/keno/ka-server/lib';
use KA;
use KA::Constants qw(FOOD_TYPES ORE_TYPES);
use DBI;
use 5.010;
my $config = KA->config->get('db');
my $db = DBI->connect($config->{dsn}, $config->{username}, $config->{password});
foreach my $resource (qw(energy water), ORE_TYPES, FOOD_TYPES) {
  my $field = $resource .'_stored'; 
  print $resource . ': ';
  say $db->do("update body set $field = 0 where $field < 0");
}






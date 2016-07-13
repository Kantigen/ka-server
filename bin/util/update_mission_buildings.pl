use strict;
use 5.010;
use lib '/home/keno/ka-server/lib';
use KA;
use Config::JSON;
use Module::Find;

$|=1;


my %buildings = map { $_ => $_->name } findallmod KA::DB::Result::Building;
my $config = Config::JSON->create('/data/KA-Mission/var/resources.conf');
$config->set('buildings', \%buildings);


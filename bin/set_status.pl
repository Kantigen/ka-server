use 5.010;
use strict;
use lib '/home/keno/ka-server/lib';
use Getopt::Long;
use KA::Cache;
use Config::JSON;
$|=1;
our $online;
our $offline;
our $gameover;
GetOptions(
    'online'        => \$online,
    'offline'       => \$offline,
    'gameover'      => \$gameover,
);

my $config = Config::JSON->new('/home/keno/ka-server/etc/reboot.conf');
my $cache = KA::Cache->new(servers => $config->get('memcached'));

if ($online) {
    say "Setting Online...";
    $cache->delete('server','status');
}
elsif ($offline) {
    say "Setting Offline...";
    $cache->set('server','status','Offline', 60 * 60 * 24 * 30);
}
elsif ($gameover) {
    say "Setting Game Over...";
    $cache->set('server','status','Game Over', 60 * 60 * 24 * 30);
}
else {
    say "Usage: $0 [ --online | --offline | --gameover ]";
}

my $status = $cache->get('server','status');
say "Current Status: ". ($status ? $status : "Online");


package KA;

use strict;
use Module::Find qw(useall);
use KA::DB;
use Config::JSON;

useall __PACKAGE__;

our $VERSION = 3.0920;

my $config = Config::JSON->new('/home/keno/ka-server/etc/keno-antigen.conf');
my $db = KA::DB->connect($config->get('db/dsn'),$config->get('db/username'),$config->get('db/password'), { mysql_enable_utf8 => 1});
my $cache = KA::Cache->new(servers => $config->get('memcached'));

#my $queue = KA::Queue->new({
#    server      => $config->get('beanstalk/server'),
#    ttr         => $config->get('beanstalk/ttr'),
#    debug       => $config->get('beanstalk/debug'),
#});

my $queue = KA::Queue->instance;

sub version {
    return $VERSION;
}

sub config {
    return $config;
}

sub db {
    return $db;
}

sub cache {
    return $cache;
}

sub queue {

    return $queue;
}

1;

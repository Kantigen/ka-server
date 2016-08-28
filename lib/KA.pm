package KA;

use strict;
use Module::Find qw(useall);
use KA::DB;
use KA::SDB;
use KA::Redis;
use Config::JSON;

useall __PACKAGE__;

our $VERSION = 3.0923;

my $config = Config::JSON->new('/home/keno/ka-server/etc/keno-antigen.conf');
my $cache = KA::Cache->new(servers => $config->get('memcached'));
my $queue = KA::Queue->instance;

sub version {
    return $VERSION;
}

sub config {
    return $config;
}

sub db {
    #return $db;
    KA::SDB->instance->db;
}

sub cache {
    return $cache;
}

sub queue {

    return $queue;
}

1;

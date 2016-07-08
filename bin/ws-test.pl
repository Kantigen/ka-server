#!/usr/bin/env perl

use strict;
use warnings;
#use v5.20;
use lib "../lib";

use Redis;

use KA::WebSocket::User;
use KA::Queue;
use KA::Config;
use KA::Redis;
use KA::SDB;
use KA::DB;
use Lacuna;

use Log::Log4perl;

# Initialize the singletons
#

# Connect to the Redis Docker image
#
my $redis = Redis->new(server => "ka-redis:6379");
KA::Redis->initialize({
    redis => $redis,
});

KA::Config->initialize;

# Connect to the beanstalk Docker image
#
KA::Queue->initialize({
    server      => "ka-beanstalkd:11300",
    
});

# Connect to the mysql Docker image
#
my $dsn = "dbi:mysql:keno:ka-mysql-server:3306";

my $db = KA::DB->connect(
    $dsn,
    'keno',
    'keno', {
        mysql_enable_utf8   => 1,
        AutoCommit          => 1,
    },
);
KA::SDB->initialize({
    db => $db,
});

my $config = Lacuna->config->get();
my $client_url = $config->{client_url};
my $condvar = AnyEvent->condvar;

Log::Log4perl->init('/home/keno/ka-server/etc/log4perl.conf');

use AnyEvent;
use AnyEvent::Socket qw(tcp_server);
use AnyEvent::WebSocket::Server;
use AnyEvent::Beanstalk;

# beanstalk sender
my $timer = AE::timer 0, 10, sub { 
    print STDERR "In 10 sec Timer!\n";

    my $queue = KA::Queue->instance();

    $queue->publish({
        queue   => 'ws_receive', 
        payload => {
            route   => '/user/hello',
            user_id => 1,
            content => {
                foo     => 'bar'
            }
        },
    });
};

$condvar->recv;
print STDERR "WE SHOULD NEVER GET HERE\n";


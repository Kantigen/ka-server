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
use KA;

use Log::Log4perl;

my $config = KA->config->get();
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
        queue   => 'mq_worker', 
        payload => {
            route   => '/starmap/getMapChunk',
            user_id => 1,
            content => {
                left    => 50,
                bottom  => -50,
            }
        },
    });
};

$condvar->recv;
print STDERR "WE SHOULD NEVER GET HERE\n";


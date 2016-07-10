#!/usr/bin/perl

use lib '/home/keno/ka-server/lib';
use Redis;
use Log::Log4perl;

use KA::Config;
use KA::Redis;
use KA::Queue;
use KA::DB;
use KA::SDB;

use KA::App::MQWorker;

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

Log::Log4perl->init('/home/keno/ka-server/etc/log4perl.conf');

my $app = KA::App::MQWorker->new_with_command();

$app->run;



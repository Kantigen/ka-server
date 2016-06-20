use strict;
use warnings;
use Test::Most;
use Log::Log4perl;

use lib "lib";
use lib "t/lib";

use Redis;
use KA::Config;
use KA::Queue;
use KA::Redis;
use KA::DB;
use KA::SDB;

use Test::Class::Moose::Load 't/tests';
use Test::Class::Moose::Runner;


#--- Initialize singleton objects
#
# Connect to the Redis Docker image
#
my $redis = Redis->new(server => $ENV{SBW_REDIS_PORT_6379_TCP_ADDR}.":".$ENV{SBW_REDIS_PORT_6379_TCP_PORT});
KA::Redis->initialize({
    redis => $redis,
});

KA::Config->initialize;

# Connect to the beanstalk Docker image
#
KA::Queue->initialize({
    server      => $ENV{SBW_BEANSTALK_PORT_11300_TCP_ADDR}.":".$ENV{SBW_BEANSTALK_PORT_11300_TCP_PORT},
    ttr         => 120,
    debug       => 0,
});

Log::Log4perl->init('/opt/code/etc/log4perl.conf');

my $db = KA::DB->connect(
    'DBI:SQLite:/opt/code/log/test.db',
);
$db->deploy({ add_drop_table => 1 });

KA::SDB->initialize({
    db => $db,
});

my $runner = Test::Class::Moose::Runner->new(statistics => 1, test_classes => \@ARGV);
$runner->runtests;
1;


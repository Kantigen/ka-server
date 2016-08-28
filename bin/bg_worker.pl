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

Log::Log4perl->init('/home/keno/ka-server/etc/log4perl.conf');

my $app = KA::App::MQWorker->new_with_command();

$app->run;



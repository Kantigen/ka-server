#!/usr/bin/env perl

use strict;
use warnings;
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

use Plack::Builder;
use Plack::App::IndexFile;
use Plack::Middleware::Headers;

my $config = KA->config->get();
my $client_url = $config->{client_url};

Log::Log4perl->init('/home/keno/ka-server/etc/log4perl.conf');

# Each of these 'servers' can potentially be on separate servers and we can add new servers to increase capacity
#   'start'     - Should always be present, it is the first place to connect to
#
#   Each of these three main sections will maintain a list of other servers to connect to for
#   the 'game', the 'chat' and the 'match' servers of which there can be many.
#
my $app = builder {
    enable 'Headers',
        set     => ['Access-Control-Allow-Origin' => $client_url];
    enable 'Headers',
        set     => ['Access-Control-Allow-Credentials' => 'true'];
    # the 'start' of the game, where you go to get connection to a game server.
    mount "/ws"            => KA::WebSocket->new({ server => 'Livingstone'  })->to_app;
};
$app;


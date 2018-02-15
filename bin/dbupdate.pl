#!/usr/bin/env perl

use App::DH;
use lib '/home/keno/ka-server/lib';
use KA;

{
    package KA::DH;
    use Moose;
    extends 'App::DH';

    has '+schema' =>
        default => sub { 'KA::DB' };
    has '+script_dir' =>
        default => sub { '/home/keno/ka-server/var/upgrades' };

    # This doesn't work because it doesn't have the user/password
    #has '+connection_name' =>
    #    default => sub { KA->config->get('db/dsn') };

    sub _build__schema {
        # we already load the connection, let's reuse it.
        KA::SDB->db
    }

    __PACKAGE__->meta->make_immutable;
}

KA::DH->new_with_options->run;

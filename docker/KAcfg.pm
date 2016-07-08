package KAcfg;

use strict;
use warnings;
use JSON;
use Cwd;
use Exporter qw(import);

# ok, not supposed to always export, but this is convenience.
our @EXPORT=qw/cfg vol $root exec_docker/;
our $root;

($root) = Cwd::abs_path(__FILE__) =~ m[^(.*/)[^/]*$];
$root =~ s[/[^/]*/?$][];

my $data = JSON::decode_json (do {
    my $fh;
    open $fh, '<', "$root/etc/docker.config" and do {
        local $/;
        <$fh>
    };
} || "{}");

my ($app) = $0 =~ m[/([^/]*?)(?:\.[^.]*)?$];
$app =~ s/^.*-ka-//;


# cfg will look for the key in the "app" section first, then global,
# and fall back to the default passed in.
# Note that the "app" section is the name of the file after "-ka-" if
# there is that part of the name, otherwise the full name.
sub cfg {
    my $default = pop;
    my $key = shift;
    $data->{$app}{$key} || $data->{$key} || $default;
}

sub vol {
    return (-v => join(':', @_) );
}

sub exec_docker {
    my $cmd         = shift;
    my $docker_opts = shift;
    my $image       = shift;
    my $cmd_opts    = shift || [];

    my @cmd = ('docker', $cmd,
        @{cfg('pre-docker-opts',[])},
        @$docker_opts,
        @{cfg('docker-opts',[])},
        $image,
        @{cfg('pre-cmd-opts',[])},
        @$cmd_opts,
        @{cfg('cmd-opts',[])},
        @ARGV
    );

    print join " ", map { /\s/ ? q["$_"]:$_ } @cmd;
    print "\n";
    exec @cmd;
}

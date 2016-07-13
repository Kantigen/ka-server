package L;

use 5.10.0;

# Intended to be used from the command line to save a bunch of typing.

# This derives off KA, thus can be used like KA:
# perl -ML -E 'say L->cache->get(...)'

use parent 'KA';
use LD;
use LR;

# for helping with scripts in bin:

use Exporter qw(import);
our @EXPORT = qw( $quiet out );

binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

our $quiet;
sub out {
    unless ($quiet) {
        say DateTime->now, " ", @_;
    }
}


1;

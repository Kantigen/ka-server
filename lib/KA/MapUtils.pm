package KA::MapUtils;

use namespace::autoclean;

use Config::JSON;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(
    assert_chunk_coords,
    normalize_x_y,
);

#--- Assert that the map chunk co-ordinates are correct
#
sub assert_chunk_coords {
    my ($sector, $left, $right) = @_;

    foreach my $arg (qw(left, bottom)) {
        if ($content->{$arg} % 50) {
            confess [1002, "$arg must be a multiple of 50"];
        }
    }

}

1;

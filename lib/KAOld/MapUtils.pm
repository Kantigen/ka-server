package KA::MapUtils;

use namespace::autoclean;

use Config::JSON;
use Carp;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(
    assert_chunk_coords
    normalize_x_y
);

#--- Assert that the map chunk co-ordinates are correct
#
sub assert_chunk_coords {
    my ($sector, $left, $right) = @_;

    my $map = KA::Config->instance->get('map');
    if (not defined $map->[$sector]) {
        confess [1002, "Sector $sector does not exist"];
    }

    if ($left % 50) {
        confess [1002, "left must be a multiple of 50"];
    }
    if ($right % 50) {
        confess [1002, "right must be a multiple of 50"];
    }
}

#--- Normalize map co-ordinates allowing for wrap-around
#
sub normalize_x_y {
    my ($sector, $x, $y) = @_;

    my $map = KA::Config->instance->get('map');
    if (not defined $map->[$sector]) {
        confess [1002, "Sector $sector does not exist"];
    }
    my $sector_config = $map->[$sector];
    my $width   = $sector_config->{x}[1] - $sector_config->{x}[0];
    my $height  = $sector_config->{y}[1] - $sector_config->{y}[1];

    $x -= $sector_config->{x}[0];
    $x = ($x % $width) + $sector_config->{x}[0];
    $y -= $sector_config->{y}[0];
    $y = ($y % $width) + $sector_config->{y}[0];
    return ($x, $y);
}

1;

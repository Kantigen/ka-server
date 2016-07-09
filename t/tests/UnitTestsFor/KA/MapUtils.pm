package UnitTestsFor::KA::MapUtils;

use lib "lib";

use Test::Class::Moose;

use KA::MapUtils qw(assert_chunk_coords normalize_x_y);

my $norm_tests = {
    '0|0|0'         => '0|0',
    '0|249|249'     => '249|249',
    '0|-249|-249'   => '-249|-249',
    '1|249|249'     => '249|249',
    '0|500|-500'    => '0|0',
    '1|-5001|5001'    => '-1|1',
};

sub test_normalize_x_y {
    my ($self) = @_;

    # Test for invalid sector
    throws_ok { normalize_x_y(55,0,0) } qr/^ARRAY/, 'Throw, invalid sector';
    is($@->[0], 1002, "Invalid sector: code");
    like($@->[1], qr/^Sector 55 does not exist$/, "Invalid sector message");

    # Test for correct normalization
    foreach my $from (sort keys %$norm_tests) {
        my ($sector, $from_x, $from_y) = split(/\|/, $from);
        my ($expect_x, $expect_y) = split(/\|/, $norm_tests->{$from});
        my ($to_x, $to_y) = normalize_x_y($sector, $from_x, $from_y);
        is($to_x, $expect_x, "Normalize X ($expect_x)");
        is($to_y, $expect_y, "Normalize Y ($expect_y)");
    }
}

sub test_assert_chunk_coords {
    my ($self) = @_;

    lives_ok { assert_chunk_coords(0,0,0) } 'expects to live 0,0,0';
    lives_ok { assert_chunk_coords(1,50,-100) } 'expects to live 1,50,-100';

    throws_ok { assert_chunk_coords(5,50,-100) }  qr/^ARRAY/, 'Invalid sector';
    throws_ok { assert_chunk_coords(1,51,-100) }  qr/^ARRAY/, 'Invalid x=51';
    throws_ok { assert_chunk_coords(0,40,-100) }  qr/^ARRAY/, 'Invalid x=40';
    throws_ok { assert_chunk_coords(0,50,-101) }  qr/^ARRAY/, 'Invalid y=-101';
}



1;


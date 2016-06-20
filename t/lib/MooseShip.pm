package MooseShip;

use Moose;
use namespace::autoclean;

has thrust_forward => (
    is      => 'rw',
    isa     => 'Num',
);


sub foo {
    my ($self, $arg) = @_;

    print STDERR "FOO $arg\n";
}
1;


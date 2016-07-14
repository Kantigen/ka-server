package KA::DB::ResultSet::Probe;

use Moose;
use utf8;
no warnings qw(uninitialized);
#use KA;

extends 'KA::DB::ResultSet';

# Search for real probes (as sent out by observatory)
#
sub search_observatory {
    my ($self, $args) = @_;

    $args = {} unless defined $args;
    $args->{virtual} = 0;

    return $self->search($args);
}

# Search for virtual probes (as seen by the Oracle)
#
sub search_oracle {
    my ($self, $args) = @_;

    $args = {} unless defined $args;
    $args->{virtual} = 1;

    return $self->search($args);
}

# Search for any probes (real or virtual)
#
sub search_any {
    my ($self, $args) = @_;

    return $self->search($args);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


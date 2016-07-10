package KA::DB::Result::Building::LCOTe;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building';
with 'KA::Role::LCOT';

use constant controller_class => 'KA::RPC::Building::LCOTe';
use constant image => 'lcotg';
use constant name => 'Lost City of Tyleon (E)';

before 'can_demolish' => sub {
    my $self = shift;
    my $f = $self->body->get_building_of_class('KA::DB::Result::Building::LCOTf');
    if (defined $f) {
        confess [1013, 'You have to demolish your Lost City of Tyleon (F) before you can demolish your Lost City of Tyleon (E).'];
    }
};

before can_build => sub {
    my $self = shift;
    my $d = $self->body->get_building_of_class('KA::DB::Result::Building::LCOTd');
    unless (defined $d) {
        confess [1013, 'You must have a Lost City of Tyleon (D) before you can build Lost City of Tyleon (E).'];
    }
    unless ($self->x == $d->x + 1 && $self->y == $d->y) {
        confess [1013, 'Lost City of Tyleon (E) must be placed to the right of the Lost City of Tyleon (D).'];
    }
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

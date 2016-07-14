package KA::DB::Result::Proposition::MembersOnlyMiningRights;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Proposition';

before pass => sub {
    my ($self) = @_;
    my $law = KA->db->resultset('Law')->new({
        name        => $self->name,
        description => $self->description,
        type        => 'MembersOnlyMiningRights',
        station_id  => $self->station_id,
    })->insert;
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

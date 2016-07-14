package KA::DB::Result::Propositions::RenameStation;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Propositions';

before pass => sub {
    my ($self) = @_;
    my $station = $self->station;
    my $name = $self->scratch->{name};
    if (KA->db->resultset('Map::Body')->search({name=>$name, 'id'=>{'!='=>$station->id}})->count) {
        $self->pass_extra_message('Unfortunately, by the time the proposition passed, the name *'.$name.'* had already taken, effectively nullifying the vote.');
    }
    else {
        $station->name($name);
        $station->update;
    }
};


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

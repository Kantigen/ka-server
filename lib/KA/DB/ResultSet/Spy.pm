package KA::DB::ResultSet::Spy;

use Moose;
use utf8;
no warnings qw(uninitialized);

extends 'KA::DB::ResultSet';

sub boost_sum {
    my ($self, $body) = @_;

    return $self->search({
        on_body_id  => $body->id,
        task        => 'Political Propaganda',
        empire_id   => $body->empire_id
    },{    
        select      => \[ "floor((me.defense + me.politics_xp)/250 + 0.5)" ],
        as          => "boost"
    })->get_column('boost')->sum;
}

1;


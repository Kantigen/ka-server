package KA::WebSocket::Context;

use Moose;
use namespace::autoclean;

has 'server' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'connection' => (
    is      => 'rw',
);

has 'content' => (
    is      => 'rw',
);

has 'client_code' => (
    is      => 'rw',
    isa     => 'Maybe[Str]',
);

has 'user' => (
    is      => 'rw',
#    isa     => 'Maybe[KA::DB::Result::User]',
);

has 'msg_id' => (
    is      => 'rw',
    isa     => 'Int',
);

# Get a parameter from the input.
#
sub param {
    my ($self, $arg) = @_;

    return ($self->content->{$arg});
}

__PACKAGE__->meta->make_immutable;


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

# Each client has a client_data area
# within which each module can store data, e.g. {user}
# to denote the logged in user.
# We store it as a hash rather than (say) a DBIC object
# in order to save space.
#
has 'client_data' => (
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


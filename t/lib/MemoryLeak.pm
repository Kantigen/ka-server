package MemoryLeak;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

has log => (
    is      => 'rw',
    default => sub {
        return Log::Log4perl->get_logger('foo');
    },
);


sub foo {
    my ($self, $arg) = @_;

    $self->log->debug("got here");
}

__PACKAGE__->meta->make_immutable;


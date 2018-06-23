package KA::MessageQueue::Context;

use Moose;
use namespace::autoclean;

has 'name' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'msg_id' => (
    is      => 'rw',
    isa     => 'Int',
);

has 'content' => (
    is      => 'rw',
);

has 'user_id' => (
    is      => 'rw',
    isa     => 'Int',
);

has 'class_data' => (
    is      => 'rw',
    isa     => 'Maybe[HashRef]',
);

has 'job' => (
    is      => 'ro',
    isa     => 'Maybe[AnyEvent::Beanstalk::Job]',
);

# touch the job to reset the ttr.  If there is no associated job,
# such as testing, then no-op.
sub touch {
    my $self = shift;
    if (my $job = $self->job)
    {
        $job->touch()->recv;
    }
}

# Get a parameter from the content.
#
sub param {
    my ($self, $arg) = @_;

    return ($self->content->{$arg});
}

__PACKAGE__->meta->make_immutable;


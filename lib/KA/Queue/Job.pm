package KA::Queue::Job;

use Moose;
use YAML;


has 'job' => (
    is          => 'ro',
    isa         => 'Beanstalk::Job',
    required    => 1,
    handles     => [qw(id buried reserved data error stats delete touch peek release bury args tube ttr priority)],
);

sub payload {
    my ($self) = @_;

    return $self->job->args;
}

__PACKAGE__->meta->make_immutable;
1;


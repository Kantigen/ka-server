package KA::Queue::Job;

use Moose;
use JSON::XS;

has 'job' => (
    is          => 'ro',
#    isa         => 'AnyEvent::Beanstalk::Job',
    required    => 1,
    handles     => [qw(id buried reserved data error stats delete touch peek release bury args tube ttr priority)],
);

sub payload {
    my ($self) = @_;

    my $payload =  decode_json($self->job->data);
}

__PACKAGE__->meta->make_immutable;
1;


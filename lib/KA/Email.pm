package KA::Email;

use Moose;

use Email::Stuff;
use File::Slurp;

use KA::Config;

sub log {
    return Log::Log4perl->get_logger( __PACKAGE__ );
}

sub send_email {
    my ($self, $options) = @_;

    my $path = '/home/keno/ka-server/var/email-templates/'.$options->{template}.'.txt';
    $self->log->debug("filename = [$path]");

    my $to_email = $options->{to};
    my $message = '';

    if (-e $path) {
        $message = read_file($path);

        unless (ref $options->{params} eq 'ARRAY') {
            $options->{params} = [];
        }

        # TODO: use a proper templating system here
        $message = sprintf($message, @{$options->{params}});
    }
    else {
        warn "Couldn't send message using $path";
    }

    if (KA::Config->instance->get('develop_mode')) {
        # Output email to logfile instead.
        $self->log->info("Sending email to $to_email:");
        $self->log->info("$message");
    } else {
        Email::Stuff->from('"Keno Antigen <noreply@kenoantigen.com>"')
            ->to($to_email)
            ->subject($options->{subject})
            ->text_body($message)
            ->send;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

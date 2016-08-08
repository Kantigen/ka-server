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
    
    if (KA::Config->instance->get('develop_mode')) {
        $to_email = KA::Config->instance->get('dev_mode_email_recipient');
    }

    if (-e $path) {
        my $message = read_file($path);

        unless (ref $options->{params} eq 'ARRAY') {
            $options->{params} = [];
        }

        $message = sprintf($message, @{$options->{params}});

        Email::Stuff->from('"Keno Antigen <noreply@kenoantigen.com>"')
            ->to($to_email)
            ->subject($options->{subject})
            ->text_body($message)
            ->send;
    }
    else {
        warn "Couldn't send message using $path";
    }
}

1;

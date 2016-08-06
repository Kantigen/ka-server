package KA::Email;

use Moose;

use Email::Stuff;

sub send_email {
    my ($self, %options) = @_;

    my $path = '/home/keno/ka-server/var/email-templates/'.$options{filename};
    my $to_email = $options{to};

    if (KA->config->get('develop_mode')) {
        $to_email = KA->config->get('dev_mode_email_recipient');
    }

    if (open my $file, "<", $path) {
        my $message;
        {
            local $/;
            $message = <$file>;
        }
        close $file;

        unless (ref $options{params} eq 'ARRAY') {
            $options{params} = [];
        }

        $message = sprintf($message, @{$options{params}});

        Email::Stuff->from('"Keno Antigen <noreply@kenoantigen.com>"')
            ->to($to_email)
            ->subject($options{subject})
            ->text_body($message)
            ->send;
    }
    else {
        warn "Couldn't send message using $path";
    }
}

1;

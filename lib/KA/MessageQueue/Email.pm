package KA::MessageQueue::Email;

use Moose;
use Log::Log4perl;
use Data::Dumper;

use KA::Email;

sub log {
    return Log::Log4perl->get_logger(__PACKAGE__);
}

#--- Send user forgot password email
#
sub bg_forgotPassword {
    my ($self, $context) = @_;

    $self->log->debug("bg_email forgot password");

    my $content = $context->content;

    KA::Email->send_email({
        template => 'forgot_password',
        to       => $content->{email},
        subject  => 'Forgotten Password',
        params => [
            $content->{username},
            'This is a url',
        ]
    });
}

#--- Send registration code email
#
sub bg_registrationCode {
    my ($self, $context) = @_;

    $self->log->debug("bg_email registration code");

    my $content = $context->content;

    KA::Email->send_email({
        template => 'registration_code',
        to       => $content->{email},
        subject  => 'Email Verification',
        params   => [
          $content->{username},
          'This is a verification code',
        ]
    });
}

1;

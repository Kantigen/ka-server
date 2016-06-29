package KA::WebSocket::User;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;
use AnyEvent::Beanstalk;

use KA::SDB;
use KA::Queue;

extends 'KA::WebSocket';

has beanstalk_client => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_beanstalk_client',
);

sub _build_beanstalk_client {
    my ($self) = @_;

    my $client = AnyEvent::Beanstalk->new(
        server  => 'ka-beanstalkd',
    );
    return $client
}

sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD: USER $self");
    $self->beanstalk_client->reserve( sub { 
        my $job = shift;
        $self->on_beanstalk_job($job);
    });
}


sub on_beanstalk_job {
    my ($self, $job) = @_;

    $self->log->debug("ON_BEANSTALK_JOB: [".Dumper($job)."]");
}



# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        message     => 'Welcome to KA User server',
    };
}


#--- Get or confirm that a clientCode is valid
#
sub ws_clientCode {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    
    my $client_code_id = $context->client_code;
    $log->debug("clientCode: client_code [$client_code_id]");
    
    my $client_code = KA::ClientCode->new({
        id  => $client_code_id,
    });

    # If the client code supplied is not valid, get another
    if (not $client_code->is_valid) {
        $log->debug("clientCode: is invalid [$client_code_id]");
        $client_code->get_new_id;
    }

    $context->client_code($client_code->id);

    $self->beanstalk_client->put({
        priority    => 100,
        ttr         => 120,
        delay       => 1,
    });

    return {
        clientCode   => $client_code->id,
    };
}

#--- Assert that the user is logged in
#
sub assert_user_is_logged_in {
    my ($self, $context) = @_;

    if (not defined $context->client_data->{user}) {
        confess [1002, "User is not logged in" ]
    }
    return $context->client_data->{user};
}

#--- Assert that the client_code is valid
#
sub assert_valid_client_code {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    $log->debug("CONTEXT: ".Dumper($context));

    if (not defined $context->client_code) {
        confess [1002, "clientCode is required." ]
    }
    my $client_code = KA::ClientCode->new({
        id      => $context->client_code,
    });

    $client_code->assert_valid;
    return $context->client_code;
}


#--- Register a new user
#
sub ws_register {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    # validate the Client Code
    $self->assert_valid_client_code($context);
    my $content = $context->content;

    # Register the account
    my $user = $db->resultset('User')->assert_create({
        username    => $content->{username},
        email       => $content->{email},
    });

    # Create a Job to send a registration email
    my $queue = KA::Queue->instance;
    $queue->publish('email_register', {
        username    => $user->username,
        email       => $user->email,
    });

    $log->debug("ws_register: return");
    return {
        loginStage  => 'enterEmailCode',
        username    => $user->username,
    };
}

#-- Forgot password
#
sub ws_forgotPassword {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    $log->debug("ws_forgotPassword: ");
    # validate the Client Code
    my $client_code = $self->assert_valid_client_code($context);

    my $username_or_email = $context->content->{usernameOrEmail} || "";
    trim $username_or_email;
    if ($username_or_email eq "") {
        confess [1002, "username_or_email is required" ];
    }

    # does username_or_email match an existing username or email
    my ($user) = $db->resultset('User')->search({
        -or     => [
            username    => $username_or_email,
            email       => $username_or_email,
        ]
    });
    if ($user) {
        # Create a Job to send a forgotten password email
        my $queue = KA::Queue->instance;
        $queue->publish('email_forgot_password', {
            username    => $user->username,
            email       => $user->email,
        });
    }

    return {};
}

#-- Login with password
#
sub ws_loginWithPassword {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    $log->debug("ws_loginWithPassword: ");

    if (defined $context->client_data->{user}) {
        confess [1666, "Already logged in. Log out first"];
    }
    # validate the Client Code
    my $client_code = $self->assert_valid_client_code($context);

    my $user = $db->resultset('User')->assert_login_with_password({
        username    => $context->content->{username},
        password    => $context->content->{password},
    });

    $context->client_data->{user} = $user->as_hash;

    return {};
}

#-- Enter New Password
#
sub ws_enterNewPassword {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    $log->debug("ws_loginWithPassword: ");
    # validate the Client Code
    my $client_code = $self->assert_valid_client_code($context);

    # validate the user is logged in
    my $user = $self->assert_user_is_logged_in($context);

    # validate the password
    $db->resultset('User')->assert_password_valid($context->content->{password});

    # Only certain registration states are allowed
    my $stage = $user->registration_stage;
    if ($stage eq 'complete' or $stage eq 'enterNewPassword') {
        return {
            loginStage  => 'complete',
        }
    }
    # otherwise the stage does not allow a password to be set
    confess [1002, 'Cannot change password yet'];
}



#-- Login with email code
#
sub ws_loginWithEmailCode {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    $log->debug("ws_loginWithEmailCode: ");
    # validate the Client Code
    my $client_code = $self->assert_valid_client_code($context);
    my $content = $context->content;

    # validate the Email Code
    my $email_code = KA::EmailCode->new({
        id      => $content->{emailCode},
        user_id => 0,
    })->assert_valid;

    $log->debug("Looking for User ID [".$email_code->user_id."]");
    my $user = $db->resultset('User')->find({
        id      => $email_code->user_id,
    });
    if (not defined $user) {
        confess [1002, "User cannot be found." ]
    }

    # User must be in correct registration stage
    if ($user->registration_stage ne 'enterEmailCode') {
        confess [1002, "Email Registration no longer valid."];
    }
    $context->user($user->as_hash);

    return {
        loginStage  => 'enterNewPassword',
        username    => $user->username,
    };
}

#--- Logout
#
sub ws_logout {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::User');
    my $db = KA::SDB->instance->db;

    $log->debug("ws_logout: ");
    # validate the Client Code
    my $client_code = $self->assert_valid_client_code($context);

    $context->user(undef);

    return {};
}
1;

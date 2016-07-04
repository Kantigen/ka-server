package KA::WebSocket::Starmap;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Time::HiRes qw(gettimeofday);

use KA::SDB;
use KA::Queue;
use KA::Config;

# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        message     => 'Welcome to KA Starmap server',
    };
}

sub log {
    my ($self) = @_;
    my $server = "Starmap";
    return Log::Log4perl->get_logger( "WS::$server" );
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

#-- Get Map Chunk
#
sub ws_get_map_chunk {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::Starmap');
    my $content = $context->{content};

    foreach my $arg (qw(left, bottom)) {
        if ($content->{$arg} % 50) {
            confess [1002, "$arg must be a multiple of 50"];
        }
    }

    my $map_size = KA::Config->instance->get('map_size');
    my $map_width = $map_size->{x}[1] - $map_size->{x}[0];
    my $map_height = $map_size->{y}[1] - $map_size->{y}[0];






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

    $self->log->debug("Time before put ".gettimeofday);

    $self->log->debug("Time after put ".gettimeofday);
    

    return {
        loginStage  => 'enterNewPassword',
        username    => $user->username,
    };
}

1;

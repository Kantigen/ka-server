package KA::WebSocket::Starmap;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Time::HiRes qw(gettimeofday);

use KA::SDB;
use KA::Queue;
use KA::Config;
use KA::MapUtils qw(assert_chunk_coords normalize_x_y);

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
sub ws_getMapChunk {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('KA::WebSocket::Starmap');
    $self->assert_valid_client_code($context);
    my $user_hash = $self->assert_user_is_logged_in($context);

    my $content = $context->{content};

    assert_chunk_coords($content->{sector}, $content->{left}, $content->{bottom});

    # For now, make all requests for map chunks a message on a MQ
    # later on we may look at caching the chunk for immediate return

    my $queue = KA::Queue->instance();

    my $job = $queue->publish({
        queue   => 'mq_starmap',
        payload => {
            route   => '/starmap/getMapChunk',
            user_id => $user_hash->{id},
            content => $content,
        },
    });
    $log->debug("GET_STAR_MAP: ".Dumper($job->recv));

}



1;

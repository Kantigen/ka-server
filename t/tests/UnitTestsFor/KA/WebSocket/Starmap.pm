package UnitTestsFor::KA::WebSocket::Starmap;

use lib "lib";
use lib "t/lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';
use Test::Exception;
use Data::Dumper;
use Log::Log4perl;

use KA::WebSocket::Starmap;
use KA::ClientCode;
use KA::EmailCode;

use UnitTestsFor::Fixtures::WebSocket::User;

sub test_construction {
    my ($self) = @_;

    my $ws_user = KA::WebSocket::Starmap->new;
    isa_ok($ws_user, 'KA::WebSocket::Starmap');
}


sub test_ws_getMapChunk {
    my ($self) = @_;

    my $content = {
        sector  => 0,
        left    => 550,
        right   => -300,
    };

    my $context = KA::WebSocket::Context->new({
        client_code => 'invalid',
        msg_id      => 545,
        content     => $content,
    });

    my $ws_user = KA::WebSocket::Starmap->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_getMapChunk($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");

    # Create a valid client code
    my $client_code = KA::ClientCode->new;
    $context->client_code($client_code->id);
   
    throws_ok { $ws_user->ws_getMapChunk($context) } qr/^ARRAY/, 'not logged in';
    is($@->[0], 1002, "Code");
    like($@->[1], qr/^User is not logged in/, "Message");
    
    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');
    $fixtures->load('user_bernard');
    $fixtures->load('user_charles');

    # User who has completed registration should be able to make the request
    my $user = $db->resultset('User')->find({
        id      => 1,
    });
    $context->client_data->{user} = $user->as_hash;

    lives_ok { $ws_user->ws_getMapChunk($context) } 'logged in';

    # Has a message been put on the message queue?
    my $queue = KA::Queue->instance;
    my $job = $queue->peek_ready;
    isnt($job, undef, "Job is ready");

    $queue->use('ws_worker');
    my $got_job = $queue->peek_ready;
    isnt($got_job, undef, "Job can be taken off queue");
    my $payload = $got_job->payload;
    diag("GOT JOB".Dumper($payload));

    is_deeply($payload, {
        user_id => 1,
        route   => '/starmap/getMapChunk',
        content => {
            left    => 550,
            right   => -300,
            sector  => 0,
        }
    }, "deep job data");

    $queue->delete($job->job->id);


}

1;

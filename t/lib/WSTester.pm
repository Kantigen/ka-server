package WSTester;

use Moose;
use namespace::autoclean;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use AnyEvent::WebSocket::Client;
use JSON;
use Data::Dumper;
use Test::More;


has 'route' => (
    is      => 'rw',
    isa     => 'Str',
    default => '/',
);

has 'server' => (
    is      => 'rw',
    isa     => 'Str',
    required    => 1,
);

has 'client_code' => (
    is      => 'rw',
    isa     => 'Str',
);

sub run_tests {
    my ($self, $tests) = @_;

    # Not ideal to make a connection for each test, but it's the easiest way
    # I have found so far!
    #
    for my $key (sort keys %$tests) {
        my $test = $tests->{$key};
    
        my $cv = AnyEvent->condvar;
        #diag("test $key");
        # We need to time-out if the connection fails to respond correctly.
        my $test_timer = AnyEvent->timer(
            after   => 2,
            cb      => sub {
                $cv->send;
                fail("Timer expired");
            },
        );

        my $client = AnyEvent::WebSocket::Client->new;
        my $connection;
        my $json;
        
        $client->connect($self->server)->cb(sub {

            $connection = eval { shift->recv };
            if ($@) {
                BAIL_OUT("Cannot connect to server [".$self->server."]");
            }

            $connection->on(finish => sub {
                my ($connection) = @_;
                #diag("FINISH signal received");
#                fail("FINISH signal received");
            #    $cv->send;
            });

            my $content = $test->{send};
            if (defined $self->client_code and not defined $content->{client_code}) {
                $content->{client_code} = $self->client_code;
            }
            $content->{msg_id} = $key;

            my $msg = JSON->new->encode({
                route   => $self->route.$test->{method},
                content => $content,
            });
            #diag("SEND: $msg");
            $connection->send($msg);

            # We should get one reply for each message

            $connection->on(each_message => sub {
                my ($connection, $message) = @_;
    
                $json = JSON->new->decode($message->body);
                my $content = $json->{content};
                #diag "RECEIVED: ".Dumper($json);
                my ($method) = $json->{route} =~ m{/([^/]*)$};;
                if ($content->{client_code}) {
                    $self->client_code($content->{client_code});
                }
                if ($method eq 'lobby_status') {
                    # We can ignore these
                }
                elsif ($method ne $test->{method}) {
                    #diag("Unexpected method '$method'");
    #                fail("Unexpected method '$method'");
                }
                else {
                    my $msg_id = $content->{msg_id} || '';
                    if ($msg_id eq $key) {
                        for my $r_key (%{$test->{recv}}) {
                            if (ref $content->{$r_key} eq "HASH") {
                                is_deeply($content->{$r_key}, $test->{recv}{$r_key}, "$msg_id - $r_key - is correct");
                            }
                            else {
                                is($content->{$r_key}, $test->{recv}{$r_key}, "$msg_id - $r_key - is correct");
                            }
                        }
                    }
                    else {
                        fail("Unexpected msg_id '$msg_id'");
                    }
                    #diag("undef timer");
                    undef $test_timer; # cancel the timer
                    $connection->close;
                    $cv->send;
                }
            });
        });
        # Go into event loop waiting for all responses
        #diag("GOT HERE!");
        $cv->recv;
        #diag("CLOSED!");
        $connection->close;
        undef $test_timer;
        # Do any tidyup (if needed)
        my $cb = $test->{callback};
        if ($cb) {
            &$cb($json);
        }
        #diag("EXIT");
    }
    #$cv->recv;
}


__PACKAGE__->meta->make_immutable;


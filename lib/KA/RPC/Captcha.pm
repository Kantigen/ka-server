package KA::RPC::Captcha;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC';
use KA::Util qw(format_date randint);
use DateTime;


sub fetch {
    my ($self, $session_id) = @_;

    my $cache   = KA->cache;
    
    my ($captcha) = KA->db->resultset('Captcha')->search(undef, { rows => 1, order_by => { -desc => 'id'} });
    if (not defined $captcha) {
        # then we have not (yet) created any captchas. Let's make a fake one
        # but not put it in the database
        $captcha = KA->db->resultset('Captcha')->new({
            riddle      => 'Answer 1',
            solution    => 1,
            guid        => 'dummy',
        });
    }
    $cache->set('captcha', $session_id, { guid => $captcha->guid, solution => $captcha->solution }, 60 * 30 );
    $cache->delete('captcha_valid', $session_id);

    # Now trigger a new captcha generation
    my $job = KA->queue->publish({
        queue   => 'bg_captcha',
        payload => {
            route   => '/captcha/generate',
            content => {},
        }
    });

    return {
        guid    => $captcha->guid,
        url     => $captcha->uri,
    };
}


sub solve {
    my $self = shift;
    my $args = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id      => $args,
            guid            => shift,
            solution        => shift,
        };
    }
    my $session_id  = $args->{session_id};
    my $guid        = $args->{guid};
    my $solution    = $args->{solution};
    
    my $cache   = KA->cache;
    my $session = $self->get_session({session_id => $session_id });

    if (defined $guid && defined $solution) {
        my $captcha = KA->cache->get_and_deserialize('captcha', $session_id);
        if (ref $captcha eq 'HASH') {
            if ($captcha->{guid} eq $guid) {
                if ($captcha->{solution} eq $solution) {
                    KA->cache->set('captcha_valid', $session_id, 1, 60 * 30 );
                    return 1;
                }
            }
        }
    }

    my $failures = $cache->incr('captcha_errors', $session_id, 1, 30 * 60);
    $cache->set('rpc_block', $session_id, $failures, $failures == 1 ? 5 : 30 * ($failures - 1));

    if ($failures > 5) {
        $session->end();
        confess [1016, 'Session error.', $session_id];
    }

    confess [1014, 'Captcha not valid.', $self->fetch($session_id)];
}

__PACKAGE__->register_rpc_method_names(
    { name => "fetch", },
    { name => "solve", },
);


no Moose;
__PACKAGE__->meta->make_immutable;


1;

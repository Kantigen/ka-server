package KA::RPC::Building::Entertainment;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';
use URI::Encode qw(uri_encode);

sub app_url {
    return '/entertainment';
}

sub model_class {
    return 'KA::DB::Result::Building::EntertainmentDistrict';
}


around 'view' => sub {
    my ($orig, $self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, $session, $building);
    $out->{ducks_quacked} = KA->cache->get('ducks','quacked');
    return $out;
};

sub get_lottery_voting_options {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;

    if ($session->is_sitter) {
        confess [1015, 'Sitters cannot enter the lottery.'];
    }
    $empire->current_session->check_captcha;
    my $cache = KA->cache;
    my @list;
    my $config = KA->config;
    my $server_url = $config->get('server_url');
    foreach my $site (@{$config->get('voting_sites')}) {
        next if $cache->get($site->{url}, $empire->id);
        push @list, {
            url     => $server_url.'entertainment/vote?session_id='.$session_id.'&building_id='.$building_id.'&site_url='.uri_encode($site->{url}, 1),
            name    => $site->{name},
        };
    }
    return {
        options         => \@list,
        status          => $self->format_status($session, $building->body),
    };
}

# no point in reinitialising this each time quack is called.
my @quacks = (
    'quack',
    'QUACK',
    'Quack',
    'Quack! Quack!',
    'Quack! Quack! Quack!',
    'Quack!!!',
    'Quaaaaaack!',
    'Q-U-A-C-K',
    ".(,)=\n~{#}~\n_|V|_",
    '|\__( o)>',
    '[kwak]',
    'noun: the harsh, throaty cry of a duck or any similar sound.',
    "       ,~~.\n      (  6 )-_,\n (\___ )=='-'\n  \ .   ) )\n   \ `-' /       \n~'`~'`~'`~'`~",
    "    ,,,,,\n   (o   o)\n    /. .\ \n   (_____)\n     : :\n    ##O##\n  ,,,: :,,,\n _)\ : : /(____\n{  \     /  ___}\n \/)     ((/\n  (_______)\n    :   :\n    :   :\n   / \ / \\n   \"\"\" \"\"\"",
    "What's up, doc?",
    "I may quack like a duck and walk like a duck, but I'm really a rabbit in disguise!",
    "Rabbit season!",
);

sub duck_quack {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    KA->cache->incr('ducks', 'quacked', 1, 60 * 60 * 24);
    return {
        status => $self->format_status($session, $building->body),
        quack  => $quacks[ rand @quacks ],
    };
}

__PACKAGE__->register_rpc_method_names(qw(duck_quack get_lottery_voting_options));


no Moose;
__PACKAGE__->meta->make_immutable;


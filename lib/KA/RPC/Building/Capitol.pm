package KA::RPC::Building::Capitol;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/capitol';
}

sub model_class {
    return 'KA::DB::Result::Building::Capitol';
}

around 'view' => sub {
    my $orig = shift;
    my $self = shift;
    my $args = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id      => $args,
            building_id     => shift,
        };
    }
    my $session  = $self->get_session($args);
    my $empire   = $session->current_empire;
    my $building = $session->current_building;

    my $out = $orig->($self, $empire, $building);
    $out->{rename_empire_cost} = $building->rename_empire_cost;
    return $out;
};


sub rename_empire {
    my $self = shift;
    my $args = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id      => $args,
            building_id     => shift,
            name            => shift,
        };
    }
    my $session  = $self->get_session($args);
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $name     = $args->{name};

    if ($empire->essentia < $building->rename_empire_cost) {
        confess [1011, "You don't have enough essentia. You need ".$building->rename_empire_cost."."];
    }
    KA::RPC::Empire->new->is_name_available($name);
    my $cache = KA->cache;
    if ($cache->get('rename_empire_lock', $empire->id)) {
        confess [1010, 'You cannot rename your empire more than once in a 24 hour period. Please wait 24 hours and try again.'];
    }

    $building->body->add_news(100, '%s has officially changed its name to %s.', $empire->name, $name);
    $empire->spend_essentia({
        amount  => $building->rename_empire_cost, 
        reason  => 'rename empire',
    });
    $empire->name($name);
    $empire->update;
    $cache->set('rename_empire_lock', $empire->id, 1, 60 * 60 * 24);

    return {
        status => $self->format_status($empire, $building->body),
    };
}

__PACKAGE__->register_rpc_method_names(qw(
    rename_empire
));


no Moose;
__PACKAGE__->meta->make_immutable;


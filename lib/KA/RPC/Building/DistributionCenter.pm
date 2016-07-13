package KA::RPC::Building::DistributionCenter;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';
with 'KA::Role::TraderRpc';

sub app_url {
    return '/distributioncenter';
}

sub model_class {
    return 'KA::DB::Result::Building::DistributionCenter';
}

around 'view' => sub {
    my ($orig, $self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id, skip_offline => 1 });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $out = $orig->($self, $session, $building);
    if ($building->is_working) {
        $out->{reserve} = {
            resources           => $building->work->{reserved},
            seconds_remaining   => $building->work_seconds_remaining,
            can                 => 0,
        };
    }
    else {
        $out->{reserve}{can}   = (eval { $building->can_reserve }) ? 1 : 0;
    }
    $out->{reserve}{max_reserve_duration} = $building->reserve_duration;
    $out->{reserve}{max_reserve_size} = $building->max_reserve_size;
    return $out;
};

sub reserve {
    my ($self, $session_id, $building_id, $resources) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->reserve($resources);
    return $self->view($session, $building);
}

sub release_reserve {
    my ($self, $session_id, $building_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    $building->release_reserve;
    return $self->view($session, $building);
}

sub dump {
    my ($self, $session_id, $building_id, $type, $amount) = @_;
	if ($amount <= 0) {
		confess [1009, 'You must specify an amount greater than 0.'];
	}
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $body = $building->body;
    $body->spend_type($type, $amount);
    $body->add_type('waste', $amount);
    $body->update;
    return {
        status      => $self->format_status($session, $body),
    };
}

__PACKAGE__->register_rpc_method_names(qw(dump reserve release_reserve get_stored_resources));


no Moose;
__PACKAGE__->meta->make_immutable;


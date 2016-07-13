package KA::RPC::Building::WaterStorage;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/waterstorage';
}

sub model_class {
    return 'KA::DB::Result::Building::Water::Storage';
}

sub dump {
    my ($self, $session_id, $building_id,  $amount) = @_;
	if ($amount <= 0) {
		confess [1009, 'You must specify an amount greater than 0.'];
	}
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $body     = $session->current_body;
    $body->spend_type('water', $amount);
    $body->add_type('waste', $amount);
    $body->update;
    return {
        status      => $self->format_status($session, $body),
        };
}

__PACKAGE__->register_rpc_method_names(qw(dump));

no Moose;
__PACKAGE__->meta->make_immutable;


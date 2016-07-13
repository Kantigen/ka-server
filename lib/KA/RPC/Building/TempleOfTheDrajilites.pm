package KA::RPC::Building::TempleOfTheDrajilites;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC::Building';

sub app_url {
    return '/templeofthedrajilites';
}

sub model_class {
    return 'KA::DB::Result::Building::Permanent::TempleOfTheDrajilites';
}


sub view_planet {
    my ($self, $session_id, $building_id, $planet_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $planet = KA->db->resultset('KA::DB::Result::Map::Body')->find($planet_id);
    
    unless (defined $planet) {
        confess [1002, 'Could not locate that planet.'];
    }
    unless ($planet->isa('KA::DB::Result::Map::Body::Planet')) {
        confess [1009, 'The Temple can only view nearby planets.'];
    }
    unless ($building->body->calculate_distance_to_target($planet) < $building->effective_level * 1000) {
        confess [1009, 'That planet is too far away.'];
    }
    
    my @map;
    my @buildings = @{$planet->building_cache};
    foreach my $building (@buildings) {
        push @map, {
            image   => $building->image_level,
            x       => $building->x,
            y       => $building->y,
        };
    }
    return {
        status  => $self->format_status($session, $building->body),
        map     => {
            surface_image   => $planet->surface,
            buildings       => \@map
        },
    };
}

sub list_planets {
    my ($self, $session_id, $building_id, $star_id) = @_;
    my $session  = $self->get_session({session_id => $session_id, building_id => $building_id });
    my $empire   = $session->current_empire;
    my $building = $session->current_building;
    my $star;
    if ($star_id) {
        $star = KA->db->resultset('KA::DB::Result::Map::Star')->find($star_id);
        unless (defined $star) {
            confess [1002, 'Could not find that star.'];
        }
    }
    else {
        $star = $building->body->star;
    }
    unless ($building->body->calculate_distance_to_target($star) < $building->effective_level * 1000) {
        confess [1009, 'That star is too far away.'];
    }    
    my @planets;
    my $bodies = $star->bodies;
    while (my $body = $bodies->next) {
        next unless $body->isa('KA::DB::Result::Map::Body::Planet');
        push @planets, {
            id      => $body->id,
            name    => $body->name,
        };
    }
    
    return {
        status  => $self->format_status($session, $building->body),
        planets => \@planets,
    };
}

__PACKAGE__->register_rpc_method_names(qw(view_planet list_planets));

no Moose;
__PACKAGE__->meta->make_immutable;


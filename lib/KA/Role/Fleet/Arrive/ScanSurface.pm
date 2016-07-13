package KA::Role::Fleet::Arrive::ScanSurface;

use strict;
use Moose::Role;

after handle_arrival_procedures => sub {
    my ($self) = @_;

    # we're coming home
    return if ($self->direction eq 'in');

    my $body_attacked = $self->foreign_body;
    # Found an asteroid
    if ($body_attacked->isa('KA::DB::Result::Map::Body::Asteroid')) {
      $self->body->empire->send_predefined_message(
            tags        => ['Attack','Alert'],
            filename    => 'scan_asteroid.txt',
            params      => ['Scanner', $body_attacked->x, $body_attacked->y, $body_attacked->name],
      );
      $self->delete;
      confess [-1];
    }
    
    # do the scan
    my @map;
    foreach my $building (@{$body_attacked->building_cache}) {
        push @map, {
            image   => $building->image_level,
            x       => $building->x,
            y       => $building->y,
        };
    }
    
    # phone home
    $self->body->empire->send_predefined_message(
        tags        => ['Attack','Alert'],
        filename    => 'scanner_data.txt',
        params      => [$self->type_formatted, $self->type_formatted, $self->name, $body_attacked->x, $body_attacked->y, $body_attacked->name],
        attachments  => {
            map => {
                surface         => $body_attacked->surface,
                buildings       => \@map
            }
        },
    );
    
    # alert empire scanned, if any
    if ($body_attacked->empire_id && defined $body_attacked->empire) {
        unless ($body_attacked->empire->skip_attack_messages) {
            $body_attacked->empire->send_predefined_message(
                tags        => ['Attack','Alert'],
                filename    => 'we_were_scanned.txt',
                params      => [$body_attacked->id, $body_attacked->name, $self->type_formatted, $self->body->empire_id, $self->body->empire->name],
            );
        }
        $body_attacked->add_news(65, sprintf('Several people reported seeing a UFO in the %s sky today.', $body_attacked->name));
    }

    my $logs = KA->db->resultset('Log::Battles');
    $logs->new({
        date_stamp => DateTime->now,
        attacking_empire_id     => $self->body->empire_id,
        attacking_empire_name   => $self->body->empire->name,
        attacking_body_id       => $self->body_id,
        attacking_body_name     => $self->body->name,
        attacking_unit_name     => $self->name,
        attacking_type          => $self->type_formatted,
        defending_empire_id     => $body_attacked->empire_id &&
                                     defined $body_attacked->empire ? $body_attacked->empire_id : undef,
        defending_empire_name   => $body_attacked->empire_id &&
                                     defined $body_attacked->empire ? $body_attacked->empire->name : undef,
        defending_body_id       => $body_attacked->id,
        defending_body_name     => $body_attacked->name,
        defending_unit_name     => '',
        defending_type          => '',
        attacked_empire_id     => $body_attacked->empire_id &&
                                     defined $body_attacked->empire ? $body_attacked->empire_id : undef,
        attacked_empire_name   => $body_attacked->empire_id &&
                                     defined $body_attacked->empire ? $body_attacked->empire->name : undef,
        attacked_body_id       => $body_attacked->id,
        attacked_body_name     => $body_attacked->name,
        victory_to              => 'attacker',
    })->insert;

    # all pow
    $self->delete;
    confess [-1];
};


1;

package KA::Role::Ship::Arrive::AddTerraformingPlatform;

use strict;
use Moose::Role;

after handle_arrival_procedures => sub {
    my ($self) = @_;

    # we're coming home
    return if ($self->direction eq 'in');
    
    # add plan
    my $lab = $self->body->get_building_of_class('KA::DB::Result::Building::TerraformingLab');
    $self->foreign_body->add_plan('KA::DB::Result::Building::Permanent::TerraformingPlatform', 1, (defined $lab) ? $lab->level : 0);
    
    # all pow
    $self->delete;
    confess [-1];
};


1;

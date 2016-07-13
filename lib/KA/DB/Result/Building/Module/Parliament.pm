package KA::DB::Result::Building::Module::Parliament;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Module';

use constant controller_class => 'KA::RPC::Building::Parliament';
use constant image => 'parliament';
use constant name => 'Parliament';
use constant max_instances_per_planet => 1;
use constant food_consumption   => 110;
use constant ore_consumption    => 110;
use constant water_consumption  =>  90;
use constant energy_consumption =>  90;

before 'can_demolish' => sub {
    confess [1010, 'You cannot demolish the Parliament. Use the abandon station function if you no longer want this station.'];
};

sub propositions {
    my ($self) = @_;
    return KA->db->resultset('KA::DB::Result::Propositions')->search({station_id => $self->body->id}, {prefetch => 'station'});
}

after downgrade => sub {
    my ($self, $theft) = @_;

    # if the parliament is downgraded such that certain laws aren't supported
    # anymore, remove those laws.

    my @unsupported_laws;
    my $level = $self->effective_level;

    push @unsupported_laws, 'Writ'                    if $level < 4;
    push @unsupported_laws, 'MembersOnlyMiningRights' if $level < 13;
    push @unsupported_laws, 'Taxation'                if $level < 15;
    push @unsupported_laws, 'MembersOnlyColonization' if $level < 18;
    push @unsupported_laws, 'MembersOnlyStations'     if $level < 18;
    push @unsupported_laws, 'MembersOnlyExcavation'   if $level < 20;
    push @unsupported_laws, 'BHGNeutralized'          if $level < 23;
    push @unsupported_laws, 'BHGPassport'             if $level < 28;

    my $laws = $self->body->laws->search(type => { in => \@unsupported_laws });
    while (my $law = $laws->next)
    {
        $law->delete;
    }

};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

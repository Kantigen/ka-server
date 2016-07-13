package KA::DB::Result::Building::Waste::Exchanger;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Waste';

use KA::Constants qw(GROWTH_F INFLATION_F CONSUME_F WASTE_S WASTE_F TINFLATE_F);

use constant controller_class => 'KA::RPC::Building::WasteExchanger';

use constant image => 'wasteexchanger';
use constant name => 'Waste Exchanger';
use constant university_prereq => 22;

use constant prod_rate => GROWTH_F;
use constant consume_rate => CONSUME_F;
use constant cost_rate => INFLATION_F;
use constant waste_prod_rate => WASTE_S;
use constant waste_consume_rate => WASTE_F;
use constant time_inflation => TINFLATE_F;

use constant energy_production => 140;
use constant ore_production => 140;
use constant water_production => 140;

use constant food_to_build => 420;
use constant energy_to_build => 460;
use constant ore_to_build => 526;
use constant water_to_build => 610;
use constant waste_to_build => 390;
use constant time_to_build => 670;

use constant food_consumption => 35;
use constant waste_consumption => 300;

use constant waste_storage => 1500;

use constant max_instances_per_planet => 2;

around 'build_tags' => sub {
    my ($orig, $class) = @_;
    return ($orig->($class), qw(Storage Energy Ore Water));
};

has max_recycle => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->effective_level * 17_500 * $self->body->empire->effective_environmental_affinity;
    },
);

has seconds_per_resource => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return 0.75 * $self->time_cost_reduction_bonus($self->effective_level * 3);
    },
);

sub can_recycle {
    my ($self, $water, $ore, $energy, $use_essentia) = @_;
    $water ||= 0;
    $ore ||= 0;
    $energy ||= 0;
    if ($self->effective_level < 1) {
        confess [1010, "You can't recycle until the Waste Exchanger is built."];
    }
    if ($self->is_working) {
        confess [1010, "The Waste Exchanger is busy."];
    }
    if ($water < 0 || $ore < 0 || $energy < 0) {
        confess [1011, "You cannot create negative resources."];
    }
    if (($water + $ore + $energy) == 0) {
        confess [1011, "You cannot recycle 0 resources."];
    }
    if (($water + $ore + $energy) > $self->body->waste_stored) {
        confess [1011, "You don't have that much waste in storage.", [($water + $ore + $energy), $self->body->waste_stored]];
    }
    if (defined $use_essentia && $use_essentia && $self->body->empire->essentia < 2) {
        confess [1011, "You don't have enough essentia to subsidize recycling."];
    }
    if (($water + $ore + $energy) > $self->max_recycle) {
        confess [1009, "You may only recycle ".$self->max_recycle." waste at a time."];
    }
    return 1;
}

sub recycle {
    my ($self, $water, $ore, $energy, $use_essentia) = @_;
    $self->can_recycle($water, $ore, $energy, $use_essentia);

    # setup
    my $body = $self->body;
    my $total = $water + $ore + $energy;
    
    # start
    my $seconds = $total * $self->seconds_per_resource;
    $seconds = 15 if $seconds < 15;
    $seconds = 5184000 if $seconds > 5184000;
    $self->start_work({
        water_from_recycling    => $water,
        ore_from_recycling      => $ore,
        energy_from_recycling   => $energy,
        }, $seconds);

    # spend
    $body->spend_waste($total);
    if ($use_essentia) {
        $body->empire->spend_essentia({
            amount  => 2, 
            reason  => 'recycling subsidy',
        });
        $body->empire->update;
        $self->finish_work;
    }
    else {
        $body->update;
        $self->update;
    }
}

before finish_work => sub {
    my $self = shift;
    my $planet = $self->body;
    $planet->add_water($self->work->{water_from_recycling});
    $planet->add_ore($self->work->{ore_from_recycling});
    $planet->add_energy($self->work->{energy_from_recycling});
    $planet->update;
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

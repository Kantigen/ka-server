package KA::DB::Result::Building::Food::Wheat;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Food';

before has_special_resources => sub {
    my $self = shift;
    my $planet = $self->body;
    my $amount_needed = sprintf('%.0f', $self->ore_to_build * $self->upgrade_cost * 0.01);
    if ($planet->gypsum_stored + $planet->sulfur_stored + $planet->monazite_stored < $amount_needed) {
        confess [1012,"You do not have a sufficient supply (".$amount_needed.") of phosphorus from sources like Gypsum, Sulfur, and Monazite to grow plants."];
    }
};

use constant controller_class => 'KA::RPC::Building::Wheat';

use constant min_orbit => 2;

use constant max_orbit => 4;

use constant image => 'wheat';

use constant name => 'Wheat Farm';

use constant food_to_build => 15;

use constant energy_to_build => 100;

use constant ore_to_build => 75;

use constant water_to_build => 20;

use constant waste_to_build => 10;

use constant time_to_build => 60;

use constant food_consumption => 1;

use constant wheat_production => 28;

use constant energy_consumption => 2;

use constant ore_consumption => 2;

use constant water_consumption => 2;

use constant waste_production => 8;


around produces_food_items => sub {
    my ($orig, $class) = @_;
    my $foods = $orig->($class);
    push @{$foods}, qw(wheat);
    return $foods;
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

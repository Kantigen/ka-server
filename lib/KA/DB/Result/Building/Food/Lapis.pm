package KA::DB::Result::Building::Food::Lapis;

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

use constant controller_class => 'KA::RPC::Building::Lapis';

use constant min_orbit => 2;

use constant max_orbit => 2;

use constant image => 'lapis';

use constant name => 'Lapis Orchard';

use constant food_to_build => 15;

use constant energy_to_build => 71;

use constant ore_to_build => 75;

use constant water_to_build => 140;

use constant waste_to_build => 5;

use constant time_to_build => 65;

use constant food_consumption => 1;

use constant lapis_production => 44;

use constant energy_consumption => 2;

use constant ore_consumption => 5;

use constant water_consumption => 5;

use constant waste_production => 13;

around produces_food_items => sub {
    my ($orig, $class) = @_;
    my $foods = $orig->($class);
    push @{$foods}, qw(lapis);
    return $foods;
};


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

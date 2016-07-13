package KA::DB::Result::Building::Capitol;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building';
use KA::Constants qw(INFLATION_F CONSUME_N WASTE_F HAPPY_F TINFLATE_F);

around 'build_tags' => sub {
    my ($orig, $class) = @_;
    return ($orig->($class), qw(Infrastructure Happiness Intelligence));
};

use constant consume_rate => CONSUME_N;
use constant cost_rate => INFLATION_F;
use constant waste_prod_rate => WASTE_F;
use constant happy_prod_rate => HAPPY_F;
use constant time_inflation => TINFLATE_F;

use constant building_prereq => {'KA::DB::Result::Building::PlanetaryCommand'=>10};

use constant max_instances_per_planet => 1;

use constant controller_class => 'KA::RPC::Building::Capitol';

use constant image => 'capitol';

use constant name => 'Capitol';

use constant food_to_build => 350;

use constant energy_to_build => 350;

use constant ore_to_build => 350;

use constant water_to_build => 350;

use constant waste_to_build => 100;

use constant time_to_build => 230;

use constant food_consumption => 18;

use constant energy_consumption => 13;

use constant ore_consumption => 2;

use constant water_consumption => 20;

use constant waste_production => 5;

use constant happiness_production => 100;

before can_build => sub {
    my $self = shift;
    my @ids = $self->body->empire->planets->get_column('id')->all;
    my $count = KA->db->resultset('KA::DB::Result::Building')->search({ class => __PACKAGE__, body_id => { in => \@ids } })->count;
    if ($count) {
        confess [1013, 'You can only have one Capitol.'];
    }
};

after finish_upgrade => sub {
    my $self = shift;
    my $body = $self->body;
    my $empire = $body->empire;
    $empire->home_planet_id($body->id);
    $empire->update;
    $body->add_news(80, '%s have announced that their new capitol is %s.', $empire->name, $body->name);
};

sub rename_empire_cost {
    my $self = shift;
    return 30 - $self->effective_level;
}


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

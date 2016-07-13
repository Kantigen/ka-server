package KA::DB::Result::Building::Permanent::InterDimensionalRift;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Permanent';

with "KA::Role::Building::UpgradeWithHalls";
with "KA::Role::Building::CantBuildWithoutPlan";

use constant controller_class => 'KA::RPC::Building::InterDimensionalRift';

use constant image => 'interdimensionalrift';

sub image_level {
    my ($self) = @_;
    return $self->image.'1';
}

after finish_upgrade => sub {
    my $self = shift;
    $self->body->add_news(50, 'An ancient interdimensional rift was opened on %s today. Onlookers stood speechless.', $self->body->name);
};

use constant name => 'Interdimensional Rift';

use constant time_to_build => 0;
use constant max_instances_per_planet => 1;
use constant energy_storage => 5000;
use constant water_storage => 5000;
use constant food_storage => 5000;
use constant ore_storage => 5000;
use constant waste_storage => 2500;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

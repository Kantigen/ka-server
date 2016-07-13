package KA::DB::Result::Building::Permanent::NaturalSpring;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Permanent';

with "KA::Role::Building::UpgradeWithHalls";
with "KA::Role::Building::CantBuildWithoutPlan";

use constant controller_class => 'KA::RPC::Building::NaturalSpring';

use constant image => 'naturalspring';

sub image_level {
    my ($self) = @_;
    return $self->image.'1';
}

after finish_upgrade => sub {
    my $self = shift;
    $self->body->add_news(30, 'Worries of drought ended today as a natural spring bubbled to the surface of %s today.', $self->body->name);
};

use constant name => 'Natural Spring';
use constant water_production => 2000;

use constant time_to_build => 0;
use constant max_instances_per_planet => 1;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

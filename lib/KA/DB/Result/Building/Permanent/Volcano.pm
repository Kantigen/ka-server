package KA::DB::Result::Building::Permanent::Volcano;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Permanent';
use KA::Util qw(randint);

with "KA::Role::Building::UpgradeWithHalls";
with "KA::Role::Building::CantBuildWithoutPlan";

use constant controller_class => 'KA::RPC::Building::Volcano';

use constant image => 'volcano';

sub image_level {
    my ($self) = @_;
    return $self->image.'1';
}

after finish_upgrade => sub {
    my $self = shift;
    $self->body->add_news(30, 'A volcano erupted on %s today spewing %s million tons of ash on the inhabitants.', $self->body->name, randint(50,250) );
};

use constant name => 'Volcano'; 
use constant ore_production => 2000;

use constant time_to_build => 0;
use constant max_instances_per_planet => 1;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

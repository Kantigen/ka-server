package KA::DB::Result::Building::Permanent::CitadelOfKnope;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building::Permanent';

use constant controller_class => 'KA::RPC::Building::CitadelOfKnope';
use KA::Util qw(randint);

with "KA::Role::Building::UpgradeWithHalls";
with "KA::Role::Building::CantBuildWithoutPlan";

use constant image => 'citadelofknope';

sub image_level {
    my ($self) = @_;
    return $self->image.'1';
}

after finish_upgrade => sub {
    my $self = shift;
    $self->body->add_news(50, 'Research students say that the Citadel of Knope, which remained dormant for years on %s, sprang to life.', $self->body->name);
};

use constant name => 'Citadel of Knope';

use constant time_to_build => 0;
use constant max_instances_per_planet => 1;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

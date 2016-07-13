package KA::DB::Result::Building::Waste;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Building';
with 'KA::Role::WasteProcessor';

around 'build_tags' => sub {
    my ($orig, $class) = @_;
    return ($orig->($class), qw(Resources Waste));
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

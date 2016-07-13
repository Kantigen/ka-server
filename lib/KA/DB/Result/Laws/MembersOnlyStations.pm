package KA::DB::Result::Laws::MembersOnlyStations;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Laws';

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

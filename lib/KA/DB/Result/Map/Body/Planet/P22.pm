package KA::DB::Result::Map::Body::Planet::P22;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Map::Body::Planet';

use constant image => 'p22';

use constant water          => 6700;
use constant rutile         => 1;
use constant chromite       => 1;
use constant chalcopyrite   => 1;
use constant galena         => 5000;
use constant gold           => 1;
use constant uraninite      => 1;
use constant bauxite        => 1;
use constant goethite       => 1;
use constant halite         => 5000;
use constant gypsum         => 1;
use constant trona          => 1;
use constant sulfur         => 1;
use constant methane        => 1;
use constant kerogen        => 1;
use constant anthracite     => 1;
use constant magnetite      => 1;
use constant fluorite       => 1;
use constant beryl          => 1;
use constant zircon         => 1;
use constant monazite       => 1;


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


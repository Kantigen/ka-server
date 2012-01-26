package Lacuna::DB::Result::Building::Archaeology;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result::Building';
use Lacuna::Constants qw(ORE_TYPES FOOD_TYPES);
use Lacuna::Util qw(randint random_element);
use Clone qw(clone);
use feature 'switch';

around 'build_tags' => sub {
    my ($orig, $class) = @_;
    return ($orig->($class), qw(Infrastructure Construction));
};

use constant max_instances_per_planet => 1;
use constant controller_class => 'Lacuna::RPC::Building::Archaeology';

use constant university_prereq => 11;

use constant image => 'archaeology';

use constant name => 'Archaeology Ministry';

use constant food_to_build => 210;

use constant energy_to_build => 240;

use constant ore_to_build => 210;

use constant water_to_build => 190;

use constant waste_to_build => 250;

use constant time_to_build => 500;

use constant food_consumption => 20;

use constant energy_consumption => 5;

use constant ore_consumption => 5;

use constant water_consumption => 30;

use constant waste_production => 20;

sub chance_of_glyph {
    my $self = shift;
    return $self->level;
}

sub is_glyph_found {
    my $self = shift;
    return rand(100) <= $self->chance_of_glyph;
}

sub get_ores_available_for_processing {
    my ($self) = @_;
    my $body = $self->body;
    my %available;
    foreach my $type (ORE_TYPES) {
        my $stored = $body->type_stored($type);
        if ($stored >= 10_000) {
            $available{ $type } = $stored;
        }
    }
    return \%available;
}

sub max_excavators {
  my $self = shift;
  return 0 if ($self->level < 15);
  return ($self->level - 14);
}

# sub add_ship {
#     my ($self, $ship) = @_;
#     $ship->task('Excavating');
#     $ship->update;
#    $self->recalc_excavating;
#     return $self;
# }

# sub send_ship_home {
#     my ($self, $body, $ship) = @_;
#     $ship->send(
#         target      => $body,
#         direction   => 'in',
#         task        => 'Travelling',
#     );
#    $self->recalc_excavating;
#     return $self;
# }

sub run_excavators {
  my $self = shift;


# Run thru excavators for each arch.
# 1) See what they find
#    Glyph, Plan, resource, (artifact), something bad
# 2) Glyph
#    a) Chances based on ore content.  (total ore)/10,000 * level
#    b) Each ore has at least 1%, but proportional to content.
# 3) Plan % equal to level/5
#    1+floor(lvl/6) possible
#    5% something special, 50% chance of 1+0, otherwise rand(1,lvl/6)
# 4) Resource Lvl * 2 percent chance
# 5) If glyph building on uninhabited excav planet
#    Chance of grabbing a lvl 1 plan of it (no dillon or e-veins)
#    Chance of 1+X up to level of arch/2+1 or level of building
#    If lvl 1 (50% chance of destroying building, or reduce by 1 level)
#    If 1+x, destroy building
# 6) Ancient Horror released. All cases, excavator destroyed. 1% chance
#    a) Ph'nglui Mglw'nafh Cthulhu R'lyeh wgah'nagi fhtagn.
#    b) Klaatu Barada Ni*cough*
#    c) Brass Doors
#    d) flutes

  my $level = $self->level;
# Do once for arch
  my $result = $self->dig_it($self->body, $level, 1);
  my @results = ($result);
  if ($level > 14) {
    my $excavators = $self->excavators;
    while (my $excav = $excavators->next) {
      my $body = $excav->body;
      my $result = $self->dig_it($body, $level, 0);
      push @results, $result;
      if ($result->{outcome} eq "Destroyed") {
        $self->remove_excavator($excav);
      }
    }
  }
  for $result (@results) {
    printf "%3d:%s - %s : %s\n",
      $result->{id}, $result->{site},
      $result->{outcome}, $result->{message};
  }
}

sub dig_it {
  my ($self, $body, $level, $arch) = @_;
  my $chances = $self->can_you_dig_it($body, $level, $arch);

  my $rnum = randint(0,100);
  my $base = 0;
  my $outcome = "nothing";
  for my $type (keys %$chances) {
    if ($rnum < $chances->{$type} + $base) {
      $outcome = $type;
      last;
    }
    $base += $chances->{$type};
  }
  my $result;
  given ($outcome) {
    when ("resource") {
      my $type = random_element([ORE_TYPES, FOOD_TYPES, qw(water energy)]);
      my $amount = randint(100 * $level, 1000 * $level);
      $self->body->add_type($type, $amount)->update;
      $result = {
        message => "Found $amount of $type.",
        outcome => "Resource",
      };
    }
    when ("plan") {
      my ($plan, $lvl, $plus, $name) = random_plan($level);
      $result = {
        message => "Found level $lvl + $plus $name Plan.",
        outcome => "Plan",
      };
    }
    when ("glyph") {
      my $glyph = $self->found_glyph($body);
      $result = {
        message => "Found a $glyph glyph.",
        outcome => "Glyph",
      };
    }
    when ("artifact") {
      my ($plan, $lvl, $plus, $name) = $self->get_artifact($body, $level);
      $result = {
        message => "Found level $lvl + $plus $name Plan.",
        outcome => "Artifact",
      };
    }
    when ("horror") {
      $result = {
        message => "Poor insane robots.",
        outcome => "Destroyed",
      };
    }
    default {
      $result = {
        message => "No results found.",
        outcome => "Nothing",
      };
    }
  }
  $result->{id} = $self->id;
  $result->{site} = $body->name;
  return $result;
}

sub get_artifact {
  my ($self, $body, $level) = @_;
  
  my $plan = 0;
  my $lvl  = 0;
  my $plus = 0;
  my $name = "pending";

  return ($plan, $lvl, $plus, $name);
}

sub found_glyph {
  my ($self, $body) = @_;

  my $glyph = "a glyph!";

  return $glyph;
}

sub random_plan {
  my ($level) = @_;

  my $plan = 0;
  my $lvl  = 0;
  my $plus = 0;
  my $name = "pending";

  return ($plan, $lvl, $plus, $name);
}

sub can_you_dig_it {
  my ($self, $body, $level, $arch) = @_;

  my $mult = $arch + 1;
  my $plan  = (int($level/5)+1) * $mult; # 1-7%
  my $ore_total = 0;
  for my $ore (ORE_TYPES) {
     $ore_total += $body->$ore;
  }
  my $glyph = int($mult * $level * $ore_total/10_000)+1; #max 1-61%
  my $resource = 2 * $level; # 2-60%
  my $artifact = 0;
  if (!$arch && $body->buildings->count) {
    $artifact = 5;
  }
  my $horror = $arch ? 0 : 1;
  my $most = $plan + $glyph + $artifact + $horror;
  if ($most + $resource > 100) {
    $resource -= ($most + $resource - 100);
  }
  my $return = {
    plan => $plan,
    glyph => $glyph,
    resource => $resource,
    artifact => $artifact,
    horror   => $horror,
  };
  return $return;
}


sub excavators {
  my $self = shift;
  return Lacuna->db->resultset('Lacuna::DB::Result::Excavators')->search({ planet_id => $self->body_id });
}

sub can_add_excavator {
  my ($self, $body, $on_arrival) = @_;
    
  # excavator count for archaeology
  my $count = $self->excavators->count;
  unless ($on_arrival) {
    $count += Lacuna->db->resultset('Lacuna::DB::Result::Ships')
                ->search({type=>'excavator', task=>'Travelling',body_id=>$self->body_id})->count;
  }
  my $max_e = $self->max_excavators;
  if ($count >= $max_e) {
    confess [1009, 'Already at the maximum number of excavators allowed at this Archaeology level.'];
  }
    
# Allowed one per empire per body.
  $count = Lacuna->db->resultset('Lacuna::DB::Result::Excavators')
             ->search({ body_id => $body->id, empire_id => $self->body->empire->id })->count;
  unless ($on_arrival) {
    $count += Lacuna->db->resultset('Lacuna::DB::Result::Ships')
                ->search( {
                    type=>'excavator',
                    foreign_body_id => $body->id,
                    task=>'Travelling',
                    body_id=>$self->body_id
                 })->count;
  }
  if ($count) {
    confess [1010, $body->name.' already has an excavator from your empire or one is on the way.'];
  }
  return 1;
}

sub add_excavator {
  my ($self, $body) = @_;
  Lacuna->db->resultset('Lacuna::DB::Result::Excavators')->new({
    planet_id   => $self->body_id,
    body_id     => $body->id,
    empire_id   => $self->body->empire->id,
  })->insert;
  return $self;
}

sub remove_excavator {
  my ($self, $excavator) = @_;
  $excavator->delete;
  return $self;
}

sub can_search_for_glyph {
    my ($self, $ore) = @_;
    unless ($self->level > 0) {
        confess [1010, 'The Archaeology Ministry is not finished building yet.'];
    }
    unless ($ore ~~ [ ORE_TYPES ]) {
        confess [1005, $ore.' is not a valid type of ore.'];
    }
    if ($self->is_working) {
        confess [1010, 'The Archaeology Ministry is already searching for a glyph.'];
    }
    unless ($self->body->type_stored($ore) >= 10_000) {
        confess [1011, 'Not enough '.$ore.' in storage. You need 10,000.'];
    }
    return 1;
}

sub search_for_glyph {
    my ($self, $ore) = @_;
    $self->can_search_for_glyph($ore);
    my $body = $self->body;
    $body->spend_ore_type($ore, 10_000);
    $body->add_waste(5000);
    $body->update;
    $self->start_work({
        ore_type    => $ore,
    }, 60*60*6)->update;
}

before finish_work => sub {
    my $self = shift;
    if ($self->is_glyph_found) {
        my $ore = $self->work->{ore_type};
        my $body = $self->body;
        $body->add_glyph($ore);
        my $empire = $body->empire;
        $empire->send_predefined_message(
            tags        => ['Alert'],
            filename    => 'glyph_discovered.txt',
            params      => [$body->id, $body->name, $ore],
            attachments => {
                image => {
                    title   => $ore,
                    url     => 'https://d16cbq0l6kkf21.cloudfront.net/assets/glyphs/'.$ore.'.png',
                }
            }
        );
        $empire->add_medal($ore.'_glyph');
        $body->add_news(70, sprintf('%s has uncovered a rare and ancient %s glyph on %s.',$empire->name, $ore, $body->name));
    }
};

sub make_plan {
    my ($self, $ids) = @_;
    unless (ref $ids eq 'ARRAY' && scalar(@{$ids}) < 5) {
        confess [1009, 'It is not possible to combine more than 4 glyphs.'];
    }

    my @glyph_names;
    my $glyphs_rs = $self->body->glyphs;
    foreach my $id (@{$ids}) {
        my $glyph = $glyphs_rs->find($id);
        confess [1002, 'You tried to combine a glyph you do not have.'] unless defined $glyph;
        push @glyph_names,$glyph->type;
    }

    my $plan_class = Lacuna::DB::Result::Plans->check_glyph_recipe(\@glyph_names);
    if (not $plan_class) {
        confess [1002, 'The glyphs specified do not fit together in that manner.'];
    }
    $glyphs_rs->search({ id => { in => $ids}})->delete;
    return $self->body->add_plan($plan_class, 1);
}

before 'can_downgrade' => sub {
  my $self = shift;
  if ($self->excavators->count > ($self->level - 15)) {
    confess [1013, 'You must abandon one of your Excavator Sites before you can downgrade the Archaeology Ministry.'];
  }
  if ($self->excavators->count && ($self->level -1) < 15 ) {
    confess [1013, 'You can not have any Excavator Sites if you are to downgrade your Archaeology Ministry below 15.'];
  }
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

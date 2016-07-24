package KA::DB::Result::Map::Body::Planet;

use Moose;
use Carp;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result::Map::Body';
use KA::Constants qw(FOOD_TYPES ORE_TYPES BUILDABLE_CLASSES SPACE_STATION_MODULES);
use List::Util qw(shuffle max min none sum);
use KA::Util qw(randint format_date random_element);
use DateTime;
use Data::Dumper;
use Scalar::Util qw(weaken);
use Log::Any;
use KA::SDB;

no warnings 'uninitialized';

use experimental "switch";

__PACKAGE__->has_many('fleets','KA::DB::Result::Fleet','body_id');
__PACKAGE__->has_many('_plans','KA::DB::Result::Plan','body_id');
__PACKAGE__->has_many('glyphs','KA::DB::Result::Glyph','body_id');
__PACKAGE__->has_many('waste_chains', 'KA::DB::Result::WasteChain','planet_id');
__PACKAGE__->has_many('out_supply_chains', 'KA::DB::Result::SupplyChain','planet_id');
__PACKAGE__->has_many('in_supply_chains', 'KA::DB::Result::SupplyChain','target_id');
__PACKAGE__->has_many('body_resources','KA::DB::Result::Resource','body_id');

has db => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_db',
);

has log => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_log',
);

has plan_cache => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_plan_cache',
    clearer => 'clear_plan_cache',
);

has resource_cache => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build_resource_cache',
    #default  => sub { my $self = shift; return $self->_build_resource_cache },
    #clearer => 'clear_resource_cache',
    predicate => 'has_resource_cache',
);

sub fleets_travelling {
    my ($self) = @_;

    my $fleets_rs = $self->fleets->search_rs({
        task    => 'Travelling',
    });
    return $fleets_rs;
}

sub _build_log {
    my ($self) = @_;
    return Log::Any->get_logger;
}

sub _build_db {
    my ($self) = @_;
    return KA::SDB->instance->db;
}

sub _build_plan_cache {
    my ($self) = @_;
    my $plans = [];
    my $plan_rs = $self->_plans->search({});
    while (my $plan = $plan_rs->next) {
        $plan->body($self);
        weaken($plan->{_relationship_data}{body});
        push @$plans,$plan;
    }
    return $plans;
}

# the 'resource_cache' is a replacement for the old $body->algae_stored etc.
#
sub _build_resource_cache {
    my ($self) = @_;

    $self->log->debug("BUILD_RESOURCE_CACHE");
    $self->log->debug("BUILD_RESOURCE_CACHE: [".$self->resource_cache."]") if $self->has_resource_cache;
    my $resources = {};
    my $resource_rs = $self->body_resources->search({});
    while (my $resource = $resource_rs->next) {
        $self->log->debug("BUILD_CACHE: new $self, $resource ".Dumper($resource->{_column_data})) if $resource->type eq 'water';
        $resources->{$resource->type} = $resource;
    }
    return $resources;
}

# Get a specific resource from the resource, or create it
#
sub get_resource {
    my ($self, $type) = @_;

    my $resource = $self->resource_cache->{$type};
    if (defined $resource) {
        return $resource;
    }
    $resource = $self->db->resultset('Resource')->new({
        body_id         => $self->id,
        type            => $type,
        production      => 0,
        consumption     => 0,
        stored          => 0,
        capacity        => 0,
    });
    $self->resource_cache->{$type} = $resource;
    $self->log->debug("GET_RESOURCE: new ".Dumper($resource->{_column_data})) if $resource->type eq 'water';
    return $resource;
}


sub get_stored {
    my ($self, $type) = @_;

    return $self->get_resource($type)->stored;
}

sub get_production {
    my ($self, $type) = @_;

    return $self->get_resource($type)->production;
}

sub get_consumption {
    my ($self, $type) = @_;
    return $self->get_resource($type)->consumption;
}

sub get_capacity {
    my ($self, $type) = @_;
    return $self->get_resource($type)->capacity;
}


# Set the amount stored
#
sub set_stored {
    my ($self, $type, $qty) = @_;
    $self->get_resource($type)->stored($qty);
}

# Set the hourly production rate
#
sub set_production {
    my ($self, $type, $qty) = @_;
    $self->get_resource($type)->production($qty);
}

# Set the hourly consumption rate
#
sub set_consumption {
    my ($self, $type, $qty) = @_;
    $self->get_resource($type)->consumption($qty);
}

# Absolutely set the total capacity of a resource
#
sub set_capacity {
    my ($self, $type, $qty) = @_;
    $self->get_resource($type)->capacity($qty);
}

# Increase the hourly production rate
#
sub add_production {
    my ($self, $type, $qty) = @_;
    my $resource = $self->get_resource($type);
    my $new_qty = $resource->production + $qty;
    $resource->production($new_qty);
}

# Increase the hourly consumption rate
#
sub add_consumption {
    my ($self, $type, $qty) = @_;
    my $resource = $self->get_resource($type);
    my $new_qty = $resource->consumption + $qty;
    $resource->consumption($new_qty);
}

# Increase the capacity
#
sub add_capacity {
    my ($self, $type, $qty) = @_;
    my $resource = $self->get_resource($type);
    my $new_qty = $resource->capacity + $qty;
    $resource->capacity($new_qty);
}

# Increase the amount stored, with no check on capacity
#
sub add_stored {
    my ($self, $type, $qty) = @_;

    my $resource = $self->get_resource($type);
    my $new_qty = $resource->stored + $qty;
    $resource->stored($new_qty);
}

# Note, stored can be negative (e.g. happiness) this must be
# dealt with externally
#
sub use_stored {
    my ($self, $type, $qty) = @_;
    my $resource = $self->get_resource($type);
    my $new_qty = $resource->stored - $qty;
    $resource->stored($new_qty);
}


after 'update' => sub {
    my ($self) = @_;

    $self->update_resources;
};

# Update the resources (store them in the database)
#
sub update_resources {
    my ($self) = @_;

    # Aggregate food and ore
    my $ore_resource = $self->get_resource('ore');
    $ore_resource->production(0);
    $ore_resource->consumption(0);
    $ore_resource->stored(0);
    my $food_resource = $self->get_resource('food');
    $food_resource->production(0);
    $food_resource->consumption(0);
    $food_resource->stored(0);

    $self->log->debug("UPDATE_RESOURCES");
    foreach my $key (keys %{$self->resource_cache}, 'ore', 'food') {
        my $resource = $self->resource_cache->{$key};

        if ($key ~~ [ORE_TYPES]) {
            $ore_resource->production($ore_resource->production + $resource->production);
            $ore_resource->consumption($ore_resource->consumption + $resource->consumption);
            $ore_resource->stored($ore_resource->stored + $resource->stored);
        }
        if ($key ~~ [FOOD_TYPES]) {
            $food_resource->production($food_resource->production + $resource->production);
            $food_resource->consumption($food_resource->consumption + $resource->consumption);
            $food_resource->stored($food_resource->stored + $resource->stored);
        }
        if ($resource->id) {
            $self->log->debug("UPDATE $resource [".$resource->type."]");
            $resource->update;
        }
        else {
            $self->log->debug("INSERT $resource");
            $resource->insert;
        }
    }
}

# Sort plans by name (asc), by level (asc), by extra_build_level (desc)
sub sorted_plans {
    my ($self) = @_;

    my @sorted_plans = sort {
            $a->class->sortable_name cmp $b->class->sortable_name 
        ||  $a->level <=> $b->level
        ||  $a->extra_build_level <=> $b->extra_build_level
        } @{$self->plan_cache};
    return \@sorted_plans;
}

sub _delete_building {
    my ($self, $building) = @_;

    my $i = 0;
    BUILDING:
    foreach my $b (@{$self->building_cache}) {
        if ($b->id == $building->id) {
            my @buildings = @{$self->building_cache};
            splice(@buildings, $i, 1);
            $self->building_cache(\@buildings);
            last BUILDING;
        }
        $i++;
    }
}
sub _delete_plan {
    my ($self, $plan) = @_;

    my $i = 0;
    BUILDING:
    foreach my $p (@{$self->plan_cache}) {
        if ($p->id == $plan->id) {
            my @plans = @{$self->plan_cache};
            splice(@plans, $i, 1);
            $self->plan_cache(\@plans);
            last BUILDING;
        }
        $i++;
    }
}

# delete buildings passed in as an array reference
sub delete_buildings {
    my ($self, $buildings) = @_;

    foreach my $building (@$buildings) {
        $self->_delete_building($building);
        $building->delete;
    }
    $self->needs_recalc(1);
    $self->needs_surface_refresh(1);
    $self->update;
}

sub delete_one_plan {
    my ($self, $plan) = @_;

    $self->delete_many_plans($plan, 1);
}

sub delete_many_plans {
    my ($self, $plan, $quantity) = @_;

    if ($plan->quantity > $quantity) {
        $plan->quantity($plan->quantity - $quantity);
        $plan->update;
    }
    else {
        $self->_delete_plan($plan);
        $plan->delete;
    }
}

sub surface {
    my $self = shift;
    return 'surface-'.$self->image;
}

# return result-set for all fleets defending or orbiting
sub fleets_orbiting {
    my ($self, $where, $reverse) = @_;

    my $order = '-asc';
    if ($reverse) {
        $order = '-desc';
    }
    $where->{task} = { in => ['Defend','Orbiting'] };
    return $self->fleets->search(
        $where,
        {
            order_by    => { $order => 'date_available' },
        }
    );
}

# return the number of ships and fleets being built on this planet
sub fleets_building {
    my ($self) = @_;

    my ($sum) = $self->db->resultset('Fleet')->search({
        body_id => $self->id,
        task    => ['Building','Repairing'],
        }, {
        "+select" => [
            { count => 'id' },
            { sum   => 'quantity' },
        ],
        "+as" => [qw(number_of_fleets number_of_ships)],
    });

    return ($sum->get_column('number_of_fleets'), $sum->get_column('number_of_ships'));
}



# claim the planet
sub claim {
    my ($self, $empire_id) = @_;
    return KA->cache->set('planet_claim_lock', $self->id, $empire_id, 60 * 60 * 24 * 3); # lock it
}

# I suspect that making this a 'default' acts as a sort of cache
# which ensures that we only see the first empire to claim this planet
has is_claimed => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return KA->cache->get('planet_claim_lock', $self->id);
    }
);

sub claimed_by {
    my $self = shift;
    my $empire_id = $self->is_claimed;
    return $empire_id ? $self->db->resultset('Empire')->find($empire_id) : undef;    
}

# add a glyph to this planet
sub add_glyph {
    my ($self, $type, $num_add) = @_;

    $num_add = 1 unless defined($num_add);

    my $glyph = $self->db->resultset('Glyph')->search({
        type    => $type,
        body_id => $self->id,
    })->first;
    if (defined($glyph)) {
        my $sum = $num_add + $glyph->quantity;
        $glyph->quantity($sum);
        $glyph->update;
    }
    else {
        $self->glyphs->new({
            type     => $type,
            body_id  => $self->id,
            quantity => $num_add,
        })->insert;
    }
}

sub use_glyph {
    my ($self, $type, $num_used) = @_;

    $num_used = 1 unless (defined($num_used));
    my $glyph = $self->db->resultset('Glyph')->search({
        type    => $type,
        body_id => $self->id,
    })->first;
    return 0 unless defined($glyph);
    if ($glyph->quantity > $num_used) {
        my $sum = $glyph->quantity - $num_used;
        $glyph->quantity($sum);
        $glyph->update;
    }
    else {
        $num_used = $glyph->quantity;
        $glyph->delete;
    }
    return $num_used;
}

# get a plan with the highest extra build level
sub get_plan {
    my ($self, $class, $level) = @_;

    my ($plan) = sort {$b->extra_build_level <=> $a->extra_build_level} grep {$_->class eq $class and $_->level == $level} @{$self->plan_cache};
    return $plan;
}

# create a new plan for this planet
sub add_plan {
    my ($self, $class, $level, $extra_build_level, $quantity) = @_;
    $quantity = 1 unless defined $quantity;

    # add it
    my ($plan) = grep {
            $_->class eq $class 
        and $_->level == $level 
        and $_->extra_build_level == $extra_build_level,
        } @{$self->plan_cache};
    if ($plan) {
        $plan->quantity($plan->quantity + $quantity);
        $plan->update;
    }
    else {
        $plan = $self->_plans->create({
            body_id             => $self->id,
            class               => $class,
            level               => $level,
            extra_build_level   => $extra_build_level,
            quantity            => $quantity,
        });
        push @{$self->plan_cache}, $plan;
    }
    return $plan;
}

# clean up the planet prior to abandoning it
sub sanitize {
    my ($self) = @_;
    my @buildings = grep {$_->class !~ /Permanent/} @{$self->building_cache};
    $self->delete_buildings(\@buildings);
    for my $building (@{$self->building_cache}) {
        $building->is_upgrading(0);
        $building->update;
    }
    $self->alliance_id(undef);
    $self->_plans->delete;
    $self->glyphs->delete;
    $self->waste_chains->delete;
    # do individual deletes so the remote ends can be tidied up too
    foreach my $chain ($self->out_supply_chains) {
        $chain->delete;
    }
    foreach my $chain ($self->in_supply_chains) {
        $chain->delete;
    }
    my $incoming = $self->db->resultset('Fleet')->search({foreign_body_id => $self->id, direction => 'out'});
    while (my $fleet = $incoming->next) {
        $fleet->turn_around->update;
    }
    $self->fleets->delete_all;
    my $enemy_spies = $self->db->resultset('Spy')->search({on_body_id => $self->id});
    while (my $spy = $enemy_spies->next) {
        $spy->on_body_id($spy->from_body_id);
        $spy->task("Idle");
        $spy->update;
    }
    $self->db->resultset('Spy')->search({from_body_id => $self->id})->delete_all;
    $self->db->resultset('Market')->search({body_id => $self->id})->delete_all;
    $self->db->resultset('MercenaryMarket')->search({body_id => $self->id})->delete_all;
    # We will delete all probes (observatory or oracle), note, must recreate oracle probes if the planet is recolonised
    $self->db->resultset('Probe')->search_any({body_id => $self->id})->delete;
    $self->empire_id(undef);
    if ($self->get_type eq 'habitable planet' &&
        $self->size >= 40 && $self->size <= 50 &&
        $self->orbit != 8 &&
        $self->zone ~~ ['1|1','1|-1','-1|1','-1|-1','0|0','0|1','1|0','-1|0','0|-1']) {
        $self->usable_as_starter_enabled(1);
    }
    $self->body_resources->delete_all;
    #$self->clear_resource_cache;
    $self->restrict_coverage(0); 
    $self->update;
    return $self;
}

before abandon => sub {
    my ($self) = @_;

    if ($self->id eq $self->empire->home_planet_id) {
        confess [1010, 'You cannot abandon your home colony.'];
    }
    $self->sanitize;
};

sub get_ore_status {
    my ($self) = @_;

    my @types = (ORE_TYPES);

    my $out;
    foreach my $type (@types) {
        my $resource = $self->get_resource($type);
        $out->{"${type}_hour"}          = $resource->production;    # DEPRECATED only for backwards compatibility
        $out->{"${type}_production"}    = $resource->production;
        $out->{"${type}_stored"}        = $resource->stored;
        $out->{"${type}_consumption"}   = $resource->consumption;
    }         
    return $out;
}

sub get_food_status {
    my ($self) = @_;

    my @types = (FOOD_TYPES);

    my $out;
    foreach my $type (@types) {
        my $resource = $self->get_resource($type);
        $out->{"${type}_hour"}          = $resource->production;    # DEPRECATED only for backwards compatibility
        $out->{"${type}_production"}    = $resource->production;
        $out->{"${type}_stored"}        = $resource->stored;
        $out->{"${type}_consumption"}   = $resource->consumption;
    }         
    return $out;
}

around get_status_lite => sub {
    my ($orig, $self, $empire) = @_;

    my $out = $self->$orig;

    if ($self->empire_id) {
        $out->{empire} = {
            name            => $self->empire->name,
            id              => $self->empire_id,
            alignment       => $self->empire->is_isolationist ? 'hostile-isolationist' : 'hostile',
            is_isolationist => $self->empire->is_isolationist,
        };
        if (defined $empire) {
            if ($empire->id eq $self->empire_id or (
                $self->isa('KA::DB::Result::Map::Body::Planet::Station') and
                $empire->alliance_id and $self->empire->alliance_id == $empire->alliance_id )) {
                $out->{empire}{alignment} = 'self',
            }
            elsif ($empire->alliance_id and $self->empire->alliance_id == $empire->alliance_id) {
                $out->{empire}{alignment} = $self->empire->is_isolationist ? 'ally-isolationist' : 'ally';
            }
        }
    }
    return $out;
};


around get_status => sub {
    my ($orig, $self, $empire) = @_;

    my $out = $orig->($self);
    my $ore;
    
    foreach my $type (ORE_TYPES) {
        $ore->{$type} = $self->$type;
    }
    $out->{ore}             = $ore;
    $out->{water}           = $self->water;
    if ($self->empire_id) {
        $out->{empire} = {
            name            => $self->empire->name,
            id              => $self->empire_id,
            alignment       => $self->empire->is_isolationist ? 'hostile-isolationist' : 'hostile',
            is_isolationist => $self->empire->is_isolationist,
        };
        if (defined $empire) {

            # IF this body is owned by the empire
            # OR this body is a station owned by this empires alliance
            # OR the empire is a sitter for this bodies owner

            if ($empire->id eq $self->empire_id 
                or (
                    $self->isa('KA::DB::Result::Map::Body::Planet::Station')
                    and $empire->alliance_id && $self->empire->alliance_id == $empire->alliance_id
                ) 
                or $empire->babies->search({id => $self->empire_id})->count ) {
                
                if ($self->needs_recalc) {
                    $self->tick; # in case what we just did is going to change our stats
                }
                # empires who have disabled the option, don't see incoming ships
                $out->{skip_incoming_ships} = $empire->skip_incoming_ships;
                if (not $empire->skip_incoming_ships) {
                    my $now = time;

                    my $foreign_bodies;
                    # Process all fleets that have already arrived

                    my $incoming_rs = $self->db->resultset('Fleet')->search({
                        foreign_body_id     => $self->id,
                        direction           => 'out',
                        task                => 'Travelling',
                        date_available      => {'<' => DateTime->now.''},
                    });
                    while (my $fleet = $incoming_rs->next) {
                        $foreign_bodies->{$fleet->body_id} = 1;
                    }
                    foreach my $body_id (keys %$foreign_bodies) {
                        my $body = $self->db->resultset('Map::Body')->find($body_id);
                        if ($body) {
                            $body->tick;
                        }
                    }

                    my $num_incoming_ally = 0;
                    my @incoming_ally;
                    # If we are in an alliance, all fleets coming from ally (which are not ourself)
                    if ($self->empire->alliance_id) {
                        my $incoming_ally_rs = $self->db->resultset('Fleet')->search({
                            foreign_body_id     => $self->id,
                            direction           => 'out',
                            task                => 'Travelling',
                            'body.empire_id'    => {'!=' => $empire->id},
                            'empire.alliance_id'  => $empire->alliance_id,
                        },{
                            join                => {body => 'empire'},
                            order_by            => 'date_available',
                        });
                        $num_incoming_ally = $incoming_ally_rs->count;
                        @incoming_ally = $incoming_ally_rs->search({},{rows => 10});
                    }
                    # All fleets coming from ourself
                    my $incoming_own_rs = $self->db->resultset('Fleet')->search({
                        foreign_body_id     => $self->id,
                        direction           => 'out',
                        task                => 'Travelling',
                        'body.empire_id'    => $empire->id,
                    },{
                        join                => 'body',
                        order_by            => 'date_available',
                    });
                    my $num_incoming_own = $incoming_own_rs->count;
                    my @incoming_own = $incoming_own_rs->search({},{rows => 10});

                    # All foreign incoming
                    my $incoming_foreign_rs = $self->db->resultset('Fleet')->search({
                        foreign_body_id     => $self->id,
                        direction           => 'out',
                        task                => 'Travelling',
                        'body.empire_id'    => {'!=' => $empire->id},
                        'empire.alliance_id'  => $self->empire->alliance_id,
                    },{
                        join                => {body => 'empire'},
                        order_by            => 'date_available',
                    });
                    if ($self->empire->alliance_id) {
                        $incoming_foreign_rs = $incoming_foreign_rs->search({
                            'empire.alliance_id' => [
                                {'!=' => $empire->alliance_id},
                                undef,
                            ]
                        });
                    }
                    my $num_incoming_foreign = $incoming_foreign_rs->count;
                    my @incoming_foreign = $incoming_foreign_rs->search({},{rows => 20});

                    $out->{num_incoming_foreign} = $num_incoming_foreign;
                    foreach my $fleet (@incoming_foreign) {
                        push @{$out->{incoming_foreign_fleets}}, {
                            date_arrives    => $fleet->date_available_formatted,
                            is_own          => 0,
                            is_ally         => 0,
                            ships           => $fleet->quantity,
                            id              => $fleet->id,
                        };
                    }
                    $out->{num_incoming_ally} = $num_incoming_ally;
                    foreach my $fleet (@incoming_ally) {
                        push @{$out->{incoming_ally_fleets}}, {
                            date_arrives    => $fleet->date_available_formatted,
                            is_own          => 0,
                            is_ally         => 1,
                            ships           => $fleet->quantity,
                            id              => $fleet->id,
                        };
                    }
                    $out->{num_incoming_own} = $num_incoming_own;
                    foreach my $fleet (@incoming_own) {
                        push @{$out->{incoming_own_fleets}}, {
                            date_arrives    => $fleet->date_available_formatted,
                            is_own          => 1,
                            is_ally         => 0,
                            ships           => $fleet->quantity,
                            id              => $fleet->id,
                        };
                    }
                }
                $out->{needs_surface_refresh} = $self->needs_surface_refresh;
                if ($self->needs_surface_refresh) {
                    $self->surface_version($self->surface_version+1);
                    $self->update;
                }
                $out->{surface_version} = $self->surface_version;

                $out->{empire}{alignment} = 'self';
                $out->{plots_available} = $self->plots_available;
                $out->{building_count}  = $self->building_count;
                $out->{build_queue_size}= $self->build_queue_size;
                $out->{build_queue_len} = $self->build_queue_length;
                $out->{population}      = $self->population;
                $out->{water_capacity}  = $self->get_capacity('water');
                $out->{water_stored}    = $self->get_stored('water');
                $out->{water_hour}      = $self->get_production('water');
                $out->{energy_capacity} = $self->get_capacity('energy');
                $out->{energy_stored}   = $self->get_stored('energy');
                $out->{energy_hour}     = $self->get_production('energy');
                $out->{food_capacity}   = $self->get_capacity('food');
                $out->{food_stored}     = $self->get_stored('food');
                $out->{food_hour}       = $self->get_production('food');
                $out->{ore_capacity}    = $self->get_capacity('ore');
                $out->{ore_stored}      = $self->get_stored('ore');
                $out->{ore_hour}        = $self->get_production('ore');
                $out->{waste_capacity}  = $self->get_capacity('waste');
                $out->{waste_stored}    = $self->get_stored('waste');
                $out->{waste_hour}      = $self->get_production('waste');
                $out->{happiness}       = $self->get_stored('happiness');
                $out->{happiness_hour}  = $self->get_production('happiness');
                if ($self->unhappy) {
                    $out->{unhappy_date} = format_date($self->unhappy_date);
                    $out->{propaganda_boost} = $self->propaganda_boost;
                }
                else {
                    $out->{propaganda_boost} = $self->propaganda_boost;
                    if (time < $self->empire->happiness_boost->epoch) {
                        $out->{propaganda_boost} = 75 if ($out->{propaganda_boost} > 75);
                    }
                    else {
                        $out->{propaganda_boost} = 50 if ($out->{propaganda_boost} > 50);
                    }
                }
                $out->{neutral_entry} = format_date($self->neutral_entry);
            }
            elsif ($empire->alliance_id && $self->empire->alliance_id == $empire->alliance_id) {
                $out->{empire}{alignment} = $self->empire->is_isolationist ? 'ally-isolationist' : 'ally';
            }
        }
    }
    return $out;
};

# resource concentrations
use constant rutile         => 1;
use constant chromite       => 1;
use constant chalcopyrite   => 1;
use constant galena         => 1;
use constant gold           => 1;
use constant uraninite      => 1;
use constant bauxite        => 1;
use constant goethite       => 1;
use constant halite         => 1;
use constant gypsum         => 1;
use constant trona          => 1;
use constant kerogen        => 1;
use constant methane        => 1;
use constant anthracite     => 1;
use constant sulfur         => 1;
use constant zircon         => 1;
use constant monazite       => 1;
use constant fluorite       => 1;
use constant beryl          => 1;
use constant magnetite      => 1;
use constant water          => 0;

# BUILDINGS

has population => (
        is      => 'ro',
        lazy    => 1,
        builder => '_build_population',
        );

sub _build_population {
    my ($self) = @_;

    my $population = sum map { $_->population } @{$self->building_cache};
    return $population;
}

has building_count => (
        is      => 'rw',
        lazy    => 1,
        builder => '_build_building_count',
        clearer => 'clear_building_count',
        );

sub _build_building_count {
    my ($self) = @_;
# Bleeders count toward building count, but supply pods don't since they can't be shot down.
    my $count = grep {$_->class !~ /Permanent/ and $_->class !~ /SupplyPod/} @{$self->building_cache}; 
    return $count;
}

# Get buildings of a specified class, ranked highest level first
sub get_buildings_of_class {
    my ($self, $class) = @_;

    my @buildings = sort {$b->level <=> $a->level} grep {$_->class eq $class} @{$self->building_cache};

    return @buildings;
}

# Get the highest level building of a specified class
sub get_building_of_class {
    my ($self, $class) = @_;
    my ($building) = sort {$b->level <=> $a->level} grep {$_->class eq $class} @{$self->building_cache};
    return $building;
}

# Find a building based on it's ID
sub find_building {
    my ($self, $id) = @_;

    my ($building) = grep {$_->id == $id} @{$self->building_cache};
    return $building;
}

# Accessor methods for specific buildings
foreach my $arg (
    [qw(trade Trade)],
    [qw(propulsion Propulsion)],
    [qw(munitions_lab MunitionsLab)],
    [qw(cloaking_lab CloakingLab)],
    [qw(pilot_training PilotTraining)],
    [qw(crashed_ship_site CrashedShipSite)],
    [qw(shipyard Shipyard)],
    [qw(planetary_command PlanetaryCommand)],
    [qw(oversight Oversight)],
    [qw(archaeology Archaeology)],
    ['mining_ministry','Ore::Ministry'],
    [qw(network19 Network19)],
    [qw(development Development)],
    ['oracle', 'Permanent::OracleOfAnid'],
    ['refinery', 'Ore::Refinery'],
    [qw(spaceport SpacePort)],
    [qw(stockpile Stockpile)],
    [qw(capitol Capitol)],
    [qw(embassy Embassy)],
    ) {
    my $method = $arg->[0];
    my $class  = $arg->[1];

    has $method => (
        is      => 'rw',
        lazy    => 1,
        default => sub {
            my ($self) = @_;
            return $self->get_building_of_class("KA::DB::Result::Building::$class");
        },
    );
}

has build_boost => (
    is      => 'rw',
    lazy    => 1,
    clearer => "clear_bb",
    default => sub {
        my $self = shift;

        my $sign = $self->get_stored('happiness') >= 0 ? 1 : -1;
        my $scale = $self->get_stored('happiness') == 0 ? 0 :
            #int
            (
                log(abs($self->get_stored('happiness'))) /
                log(1000)
               );
            #1 - $sign * $scale * ($sign < 0 ? 10 : 2) / 100;
        1 - $sign * $scale * ($sign < 0 ? 150 : 4) / 100;
    },
);


sub is_space_free {
    my ($self, $unclean_x, $unclean_y) = @_;
    my $x = int( $unclean_x );
    my $y = int( $unclean_y );
    return none {$_->x == $x and $_->y == $y} @{$self->building_cache};
}

sub find_free_spaces
{
    my $self = shift;
    my $args = shift // {};
    my $size = $args->{size} // 1; # 4 = SSL (want top-left), 9 = LCOT (want middle)

    # this option is not yet well-tested.
    my $col6 = $args->{outer};
    die "Incorrect usage (size must be one with outer set to true)"
        if $col6 && $size > 1;

    # I have no idea how to make this query in DBIC, so resort to direct
    # SQL calls.
    my $dbh = $self->db->storage->dbh();

    my $gen_tmp = sub {
        my $col = shift;
        my $first = shift;
        join ' ', "select '$first' as $col", map { "union all select '$_'" } @_;
    };
    my $tmp_x = $gen_tmp->('x', $col6 ? (6) : (-5..5));
    my $tmp_y = $gen_tmp->('y', -5..5);

    my $sql = <<"EOSQL";
select v.x,w.y
  from 
   ($tmp_x) as v
  join
   ($tmp_y) as w
  left join
   (select x,y,id from building where body_id = ?) as b
    on 
      b.x = v.x and b.y = w.y
  where
   b.id is null
EOSQL

    my $sth = $dbh->prepare_cached($sql);
    $sth->execute($self->id);

    my $o = $sth->fetchall_arrayref;

    if ($size > 1 && @$o)
    {
        my (@x_offsets,@y_offsets);

        if ($size == 9)
        {
            @x_offsets = @y_offsets = (-1..1);
        }
        elsif ($size == 4)
        {
            @x_offsets = (-1..0);
            @y_offsets = (0..1);
        }
        else
        {
            die "Unexpected size: $size";
        }

        # put them all in a hash for easier tracking.
        my %free;
        for my $c (@$o)
        {
            for my $x_off (@x_offsets)
            {
                for my $y_off (@y_offsets)
                {
                    my $x = $c->[0] + $x_off;
                    my $y = $c->[1] + $y_off;
                    $free{"$x,$y"}++;
                }
            }
        }

        # sort it for easier debugging.
        return [ sort {
            $a->[0] <=> $b->[0] ||
            $a->[1] <=> $b->[1]
        } map {
            [ split ',', $_ ]
        } grep {$free{$_} == $size} keys %free
        ];
    }
    return $o;
}

sub find_free_space {
    my $self = shift;
    my $open_spaces = $self->find_free_spaces();

    confess [1009, 'No free space found.'] unless @$open_spaces;

    return @{random_element($open_spaces)};
}

sub has_outgoing_ships {
    my ($self, $min) = @_;
    my $ships = $self->db->resultset('Fleet')->search({
            body_id         => $self->id,
            task            => 'Travelling',
    });
    my $count = $ships->count;
    return 1 if $count >= $min;
    return 0;
}

# Check if the given co-ordinates are a valid building spot
sub check_for_available_build_space {
    my ($self, $unclean_x, $unclean_y) = @_;
    my $x = int( $unclean_x );
    my $y = int( $unclean_y );
    
    if ($x > 5 || $x < -5 || $y > 5 || $y < -5) {
        confess [1009, "That's not a valid space for a building.", [$x, $y]];
    }
    unless ($self->is_space_free($x, $y)) {
        confess [1009, "That space is already occupied.", [$x,$y]]; 
    }
    return 1;
}

# Are there any free building plots available
sub check_plots_available {
    my ($self, $building) = @_;

    if (!$building->isa('KA::DB::Result::Building::Permanent') && $self->plots_available < 1) {
        confess [1009, "You've already reached the maximum number of buildings for this planet.", $self->size];
    }
    return 1;
}

# have we met all the pre-requisites to build this building?
sub has_met_building_prereqs {
    my ($self, $building, $cost) = @_;

    $building->can_build($self);
    $self->has_resources_to_build($building, $cost);
    $self->has_max_instances_of_building($building);
    $self->has_resources_to_operate($building);
    return 1;
}

# can we build this building at this time? 
sub can_build_building {
    my ($self, $building) = @_;

    $self->check_for_available_build_space($building->x, $building->y);
    $self->check_plots_available($building);
    $self->has_room_in_build_queue;
    $self->has_met_building_prereqs($building);
    return $self;
}

has build_queue_size => (
                         is => 'ro',
                         lazy => 1,
                         default => sub {
                             my $self = shift;
                             my $max = 1;
                             my $dev_min = $self->development;
                             $max += $dev_min->effective_level if $dev_min;
                             $max;
                         }
                        );

sub build_queue_length {
    my $self = shift;
    scalar @{$self->builds};
}

# is there room left in the build queue?
sub has_room_in_build_queue {
    my ($self) = @_;

    my $max = 1;
    if (defined $self->development) {
        $max += $self->development->level;
    }
    my $count = @{$self->builds};
    if ($count >= $max) {
        confess [1009, "There's no room left in the build queue.", $max];
    }
    return 1; 
}

use constant operating_resource_names => qw(food energy ore water);

# Get the operating costs when all builds are complete
has future_operating_resources => (
    is      => 'rw',
    clearer => 'clear_future_operating_resources',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        
        # get current
        my %future;
        foreach my $type ($self->operating_resource_names) {
            $future{$type.'_hour'} = $self->get_production($type);
        }

        # adjust for what's already in build queue
        my @queued_builds = @{$self->builds};
        foreach my $build (@queued_builds) {
            my $other = $build->stats_after_upgrade;
            foreach my $type ($self->operating_resource_names) {
                my $method = $type.'_hour';
                $future{$method} += $other->{$type} - $build->$method;
            }
        }
        return \%future;
    },
);

# would we have enough resources to operate this building in the future?
sub has_resources_to_operate {
    my ($self, $building) = @_;

    # get future
    my $future = $self->future_operating_resources; 

    # get change for this building
    my $after = $building->stats_after_upgrade;

    # check our ability to sustain ourselves
    foreach my $type ($self->operating_resource_names) {
        my $method = $type.'_hour';
        my $delta = $after->{$method} - $building->$method;
        # don't allow it if it sucks resources && its sucking more than we're producing
        if ($delta < 0 && $future->{$method} + $delta < 0) {
            confess [1012, "Unsustainable given the current and planned resource consumption. Not enough resources being produced to build this.", $type];
        }
    }
    return 1;
}

# would we have enough resources to operate everything after this building is demolished?
sub has_resources_to_operate_after_building_demolished {
    my ($self, $building) = @_;

    # get future
    my $future = $self->future_operating_resources;

    # check our ability to sustain ourselves
    foreach my $type ($self->operating_resource_names) {
        # don't allow it if it sucks resources && its sucking more than we're producing
        my $method = $type.'_hour';
        if ($future->{$method} - $building->$method < 0) {
            confess [1012, "Unsustainable. Not enough resources being produced by other sources to destroy this.", $type];
        }
    }
    return 1;
}

# do we have sufficient resources to construct this building?
sub has_resources_to_build {
    my ($self, $building, $cost) = @_;

    $cost ||= $building->cost_to_upgrade;
    foreach my $resource (qw(food energy ore water)) {
        if ($self->get_stored($resource) < $cost->{$resource}) {
            confess [1011, "Not enough $resource in storage to build this.", $resource];
        }
    }
    if ($cost->{waste} < 0) { # we're spending waste to build a building, which is unusal, but not wrong
        if ($self->get_stored('waste') < abs($cost->{waste})) {
            confess [1011, "Not enough waste in storage to build this.", 'waste'];
        }
    }
    return 1;
}

# do we already have the maximum number of this type of building?
sub has_max_instances_of_building {
    my ($self, $building) = @_;

    return 0 if $building->max_instances_per_planet == 9999999; # TODO what's this all about?
    my $buildings = grep {$_->class eq $building->class} @{$self->building_cache};

    if ($buildings >= $building->max_instances_per_planet) {
        confess [1009, sprintf("You are only allowed %s of these buildings per planet.",$building->max_instances_per_planet)];
    }
}

# return all buildings currently being upgraded
sub builds { 
    my ($self, $reverse) = @_;

    my @buildings = sort {$a->upgrade_ends cmp $b->upgrade_ends} grep {$_->is_upgrading == 1} @{$self->building_cache};
    @buildings = reverse @buildings if $reverse;
    return \@buildings;
}

# get the time when the build queue will be completed 
sub get_existing_build_queue_time {
    my ($self) = @_;

    my ($building) = @{$self->builds(1)};

    return (defined $building) ? $building->upgrade_ends : DateTime->now;
}

sub lock_plot {
    my ($self, $x, $y) = @_;
    return KA->cache->set('plot_contention_lock', $self->id.'|'.$x.'|'.$y, 1, 15); # lock it
}

sub is_plot_locked {
    my ($self, $x, $y) = @_;
    return KA->cache->get('plot_contention_lock', $self->id.'|'.$x.'|'.$y);
}

# put a building on the build queue
sub build_building {
    my ($self, $building, $in_parallel, $no_upgrade) = @_;

    unless ($building->isa('KA::DB::Result::Building::Permanent')) {
        $self->building_count( $self->building_count + 1 );
        $self->plots_available( $self->plots_available - 1 );
        $self->update;
    }
    $building->date_created(DateTime->now);
    $building->body_id($self->id);
    $building->level(0) unless $building->level;
    $building->insert;
    $building->body($self);
    weaken($building->{_relationship_data}{body});
    unless ($no_upgrade) {
        $building->start_upgrade(undef, $in_parallel);
    }
    $self->building_cache([@{$self->building_cache}, $building]);
}

# create a new colony on this planet
sub found_colony {
    my ($self, $empire) = @_;

    $self->empire_id($empire->id);
    $self->usable_as_starter_enabled(0);
    $self->last_tick(DateTime->now);
    $self->update;    

    # Excavators get cleared when being checked for results.

    # award medal
    my $type = ref $self;
    $type =~ s/^.*::(\w\d+)$/$1/;
    $empire->add_medal($type);

    # delete anything that may be on the PCC plot
    my ($building) = grep {$_->x == 0 and $_->y == 0} @{$self->building_cache};
    if (defined $building) {
        $building->delete;
    }

    # add command building
    my $command = $self->db->resultset('Building')->new({
        x       => 0,
        y       => 0,
        class   => 'KA::DB::Result::Building::PlanetaryCommand',
        level   => $empire->growth_affinity - 1,
    });
    $self->build_building($command);
    $command->finish_upgrade;

    my @craters = grep {$_->work eq '{}'} $self->get_buildings_of_class('KA::DB::Result::Building::Permanent::Crater');
    foreach my $crater (@craters) {
        $crater->finish_work->update;
    }

    # recreate virtual probes if there's already an oracle here.
    if (my $oracle = $self->oracle) {
        my $ends = DateTime->now->add(seconds => 60);
        if ($oracle->is_working) {
            $oracle->reschedule_work($ends)
        }
        else {
            $oracle->start_work({}, 60);
        }
    }

    # Initialize body
    $self->restrict_coverage(0);
    $self->body_resources->delete_all;
    #$self->clear_resource_cache;

    # add starting resources
    $self->needs_recalc(1);
    $self->tick;
    $self->add_algae(700);
    $self->add_energy(700);
    $self->add_water(700);
    $self->add_random_ore(700);
    $self->set_stored('happiness', 0);
    $self->update;

    # newsworthy
    $self->add_news(75,'%s founded a new colony on %s.', $empire->name, $self->name);

    return $self;
}

# convert this planet into a station
sub convert_to_station {
    my ($self, $empire) = @_;

    $self->size(3);
    $self->plots_available(0);
    $self->empire_id($empire->id);
#    $self->empire($empire);
#    weaken($self->{_relationship_data}{empire});

    $self->usable_as_starter_enabled(0);
    $self->last_tick(DateTime->now);
    $self->alliance_id($empire->alliance_id);
    $self->class('KA::DB::Result::Map::Body::Planet::Station');
    $self->update;    

    # award medal
    $empire->add_medal('space_station_deployed');

    # clean it
    my @all_buildings = @{$self->building_cache};
    $self->delete_buildings(\@all_buildings);
    $self->_plans->delete;
    $self->glyphs->delete;

    # add command building
    my $command = $self->db->resultset('Building')->new({
        x       => 0,
        y       => 0,
        class   => 'KA::DB::Result::Building::Module::StationCommand',
    });
    $self->build_building($command);
    $command->finish_upgrade;

    # add parliament
    my $parliament = $self->db->resultset('Building')->new({
        x       => -1,
        y       => 0,
        class   => 'KA::DB::Result::Building::Module::Parliament',
    });
    $self->build_building($parliament);
    $parliament->finish_upgrade;

    # add warehouse
    my $warehouse = $self->db->resultset('Building')->new({
        x       => 1,
        y       => 0,
        class   => 'KA::DB::Result::Building::Module::Warehouse',
    });
    $self->build_building($warehouse);
    $warehouse->finish_upgrade;

    # add starting resources
    $self->tick;
    $self->add_algae(2500);
    $self->add_energy(2500);
    $self->add_water(2500);
    $self->add_rutile(2500);
    $self->update;

    # newsworthy
    $self->add_news(100,'%s deployed a space station at %s.', $empire->name, $self->name);

    return $self;
}

# total ore concentration of this planet
has total_ore_concentration => (
    is          => 'ro',  
    lazy        => 1,
    default     => sub {
        my ($self) = @_;

        my $tally = 0;
        foreach my $type (ORE_TYPES) {
            $tally += $self->$type;
        }
        return $tally;
    },
);

# Check if a resource is a food type
sub is_food {
    my ($self, $resource) = @_;

    if (grep {$resource eq $_} (FOOD_TYPES)) {
        return 1;
    }
    return;
}

# Check if a resource is an ore type
sub is_ore {
    my ($self, $resource) = @_;

    if (grep {$resource eq $_} (ORE_TYPES)) {
        return 1;
    }
    return;
}

# convert a resource name into a planet attribute name
sub resource_name {
    my ($self,$resource) = @_;

    if ($self->is_food($resource)) {
        return $resource.'_production_hour';
    }
    return $resource.'_hour';
}

# Recalculate waste and supply chains for this body
sub recalc_chains {
    my ($self) = @_;

    if ($self->trade) {
        $self->trade->recalc_supply_production;
        $self->trade->recalc_waste_production;
    }
}

# recalculate all stats for this body
sub recalc_stats {
    my ($self) = @_;

    $self->log->debug("RECALC_STATS");
#    $self->clear_building_cache;

    my %stats = ( needs_recalc => 0 );
    #reset foods and ores
    foreach my $type (FOOD_TYPES) {
        $self->set_production($type, 0);
    }
    foreach my $type (ORE_TYPES) {
        $self->set_production($type, 0);
    }
    $stats{max_berth} = 1;
    #calculate propaganda bonus
    my $spy_boost = $self->db->resultset('Spy')->boost_sum($self);

    $self->propaganda_boost($spy_boost);
    $self->update;

    #calculate building production
    my ($gas_giant_platforms, $terraforming_platforms, $station_command,
        $pantheon_of_hagness, $fissure_percent) = 0;

    foreach my $type (qw(waste water energy food ore happiness)) {
        $self->set_capacity($type, 0);
        $self->set_production($type, 0);
    }

    foreach my $building (@{$self->building_cache}) {
        
        $self->add_capacity('waste',  $building->waste_capacity);
        $self->add_capacity('water',  $building->water_capacity);
        $self->add_capacity('energy', $building->energy_capacity);
        $self->add_capacity('food',   $building->food_capacity);
        $self->add_capacity('ore',    $building->ore_capacity);

        $self->add_production('happiness',  $building->happiness_hour);
        $self->add_production('waste',      $building->waste_hour);
        $self->add_production('energy',     $building->energy_hour);
        $self->add_production('water',      $building->water_hour);

        $self->add_consumption('food',      $building->food_consumption_hour);
        $self->add_consumption('ore',       $building->ore_consumption_hour);
        $self->add_production('ore',        $building->ore_production_hour);

        foreach my $type (@{$building->produces_food_items}) {
            my $method = $type.'_production_hour';
            $self->add_production($type, $building->$method);
            $self->add_production('food', $building->$method);
        }

        if ($building->isa('KA::DB::Result::Building::SpacePort') and $building->effective_efficiency == 100) {
            $stats{max_berth} = $building->effective_level if ($building->effective_level > $stats{max_berth});
        }
        if ($building->isa('KA::DB::Result::Building::Ore::Ministry')) {
            my $platforms = $self->db->resultset('MiningPlatform')->search({planet_id => $self->id});
            while (my $platform = $platforms->next) {
                foreach my $type (ORE_TYPES) {
                    my $method = $type.'_hour';
                    $self->add_production($type, $platform->$method);
                }
            }
        }
        if ($building->isa('KA::DB::Result::Building::Trade')) {
            # Calculate the amount of waste to deduct based on the waste_chains
            my $waste_chains = $self->db->resultset('WasteChain')->search({planet_id => $self->id});
            while (my $waste_chain = $waste_chains->next) {
                my $percent = $waste_chain->percent_transferred;
                $percent = $percent > 100 ? 100 : $percent;
                $percent *= $building->effective_efficiency / 100;
                my $waste_hour = sprintf('%.0f',$waste_chain->waste_hour * $percent / 100);
                $self->add_production('waste', 0-$waste_hour);
            }
            # calculate the resources being chained *from* this planet
            my $output_chains = $self->out_supply_chains->search({
                stalled     => 0,
            });
            while (my $out_chain = $output_chains->next) {
                my $percent = $out_chain->percent_transferred;
                $percent    = $percent > 100 ? 100 : $percent;
                $percent    *= $building->effective_efficiency / 100;

                my $resource_hour = sprintf('%.0f',$out_chain->resource_hour * $percent / 100);
                $self->add_production($out_chain->resource_type, 0-$resource_hour);
            }
        }
        if ($building->isa('KA::DB::Result::Building::Permanent::GasGiantPlatform')) {
            $gas_giant_platforms += int($building->effective_level * $building->effective_efficiency/100);
        }
        if ($building->isa('KA::DB::Result::Building::Permanent::TerraformingPlatform')) {
            $terraforming_platforms += int($building->effective_level * $building->effective_efficiency/100);
        }
        if ($building->isa('KA::DB::Result::Building::Permanent::PantheonOfHagness')) {
            $pantheon_of_hagness += int($building->effective_level * $building->effective_efficiency/100);
        }
        if ($building->isa('KA::DB::Result::Building::Module::StationCommand')) {
            $station_command += $building->effective_level;
        }
        if ($building->isa('KA::DB::Result::Building::Permanent::Fissure')) {
            # A fissure is controlled by maintenance equipment. The less efficient
            # the equipment, the more energy the Fissure will suck in.
            # Fissure affect on energy_hour is 1% per level subject to efficiency
            $fissure_percent += $building->effective_level * (100 - $building->effective_efficiency) / 100;
        }
    }
    # Energy reduced by Fissure action
    my $new_energy = $self->get_production('energy') - $self->get_production('energy') * $fissure_percent / 100;
    $self->set_production('energy', $new_energy);

    # active supply chains sent *to* this planet
    my $input_chains = $self->in_supply_chains->search({
        stalled     => 0,
    },{
        prefetch => 'building',
    });

    while (my $in_chain = $input_chains->next) {
        my $percent = $in_chain->percent_transferred;
        $percent = $percent > 100 ? 100 : $percent;
        $percent *= $in_chain->building->effective_efficiency / 100;
        my $resource_hour = sprintf('%.0f',$in_chain->resource_hour * $percent / 100);
        $self->add_production($in_chain->resource_type, $resource_hour);
    }

    # local ore production
    foreach my $type (ORE_TYPES) {
        my $domestic_ore_hour = sprintf('%.0f',$self->$type * $self->get_production('ore') / $self->total_ore_concentration);
        $self->add_production($type, $domestic_ore_hour);
    }
    $self->update;
    $self->discard_changes;
    
    # deal with negative amounts stored
    $self->set_stored('water',0) if $self->get_stored('water') < 0;
    $self->set_stored('energy',0) if $self->get_stored('energy') < 0;
    for my $type (FOOD_TYPES, ORE_TYPES) {
        $self->set_stored($type, 0) if ($self->get_stored($type) < 0);
    }
    $self->update;
    $self->discard_changes;
    
    # deal with storage overages
    if ($self->get_stored('ore') > $self->get_capacity('ore')) {
        $self->spend_ore($self->get_stored('ore') - $self->get_capacity('ore'));
    }
    if ($self->get_stored('food') > $self->get_capacity('food')) {
        $self->spend_food($self->get_stored('food') - $self->get_capacity('food'), 1);
    }
    if ($self->get_stored('water') > $self->get_capacity('water')) {
        $self->spend_water($self->get_stored('water') - $self->get_capacity('water'));
    }
    if ($self->get_stored('energy') > $self->get_capacity('energy')) {
        $self->spend_energy($self->get_stored('energy') - $self->get_capacity('energy'));
    }

    # deal with plot usage
    my $max_plots = $self->size + $pantheon_of_hagness;
    if ($self->isa('KA::DB::Result::Map::Body::Planet::GasGiant')) {
        $max_plots = min($gas_giant_platforms, $max_plots);
    }
    elsif ($self->isa('KA::DB::Result::Map::Body::Planet::Station')) {
        $max_plots = $stats{size} = $station_command * 3;
    }
    elsif ($self->isa('KA::DB::Result::Map::Body::Planet')) {
        if ($self->empire) {
            if ($self->orbit > $self->empire->max_orbit || $self->orbit < $self->empire->min_orbit) {
                $max_plots = min($terraforming_platforms, $max_plots);
            }
        }
    }
    # Adjust happiness_hour to maximum of 30 days from where body went negative. Different max for positive happiness.
    # If using spies to boost happiness rate, best rate can be a bit variable.
    if ($self->unhappy == 1) {
        my $happy = $self->get_stored('happiness');
        my $max_rate =    150_000_000_000 * ((time < $self->empire->happiness_boost->epoch) ? 1.25 : 1);
        my $max_time =    720 / ((time < $self->empire->happiness_boost->epoch) ? 1.25 : 1);
        my $one_twenty =  120 / ((time < $self->empire->happiness_boost->epoch) ? 1.25 : 1);
        if ($happy < -1 * ($one_twenty * 150_000_000_000)) {
            my $div = 1;
            my $unhappy_time = DateTime->now->subtract_datetime_absolute($self->unhappy_date);
            my $unh_hours = $unhappy_time->seconds/(3600);
            if ($unh_hours < $max_time) {
                $div = $max_time - $unh_hours;
            }
            my $new_rate = int(abs($self->get_stored('happiness'))/$div);
            $max_rate = $new_rate if $new_rate > $max_rate;
        }
        $self->set_production('happiness', $max_rate) if ($self->get_production('happiness') > $max_rate);
    }

    $stats{plots_available} = $max_plots - $self->building_count;

    # Decrease happiness production if short on plots.
    if ($stats{plots_available} < 0) {
        my $plot_tax = int(50 * 1.62 ** (abs($stats{plots_available})-1));
        
        # Set max to at least -10k
        my $neg_hr = $self->get_stored('happiness') > 100_000 ? -1 * $self->get_stored('happiness')/10 : -10_000;
        my $happy_hour = $self->get_production('happiness');

        if ( $happy_hour < 0 and $happy_hour > $neg_hr) {
            $self->set_production('happiness', $neg_hr);
        }
        elsif ( ( $happy_hour - $neg_hr) < $plot_tax) {
            $self->set_production('happiness', $neg_hr);
        }
        else {
            $self->add_production('happiness',  0-$plot_tax);
        }
        $self->set_production('happiness', -100_000_000_000) if ($self->get_production('happiness') < -100_000_000_000);
    }
    $self->update;
    $self->discard_changes;
    $self->update(\%stats);

    return $self;
}

# NEWS
sub add_news {
    my ($self, $chance, $headline) = @_;

    if ($self->restrict_coverage) {
        my $network19 = $self->network19;
        if (defined $network19) {
            $chance += $network19->level * 2;
            $chance = $chance / $self->planetary_command->level; 
        }
    }
    if (randint(1,100) <= $chance) {
        $headline = sprintf $headline, @_ if @_;
        $self->db->resultset('News')->new({
            date_posted => DateTime->now,
            zone        => $self->zone,
            headline    => $headline,
        })->insert;
        return 1;
    }
    return 0;
}


# RESOURCE MANGEMENT
sub tick {
    my ($self) = @_;
    
    # stop a double tick
    my $cache = KA->cache;
    if ($cache->get('ticking',$self->id)) {
        return undef;
    }
    else {
        $cache->set('ticking',$self->id, 1, 30);
    }
    
    my $now = DateTime->now;
    my $now_epoch = $now->epoch;

    # check / clear boosts
    if ($self->boost_enabled) {
        my $empire = $self->empire;
        if ($empire) {
            my $still_enabled = 0;
            foreach my $resource (qw(energy water ore happiness food storage building spy_training)) {
                my $boost = $resource.'_boost';
                if ($now_epoch > $empire->$boost->epoch) {
                    $self->needs_recalc(1);
                }
                else {
                    $still_enabled = 1;
                }
            }
            unless ($still_enabled) {
                # avoid each planet sending the same boost expired message
                if (!$self->empire->check_for_repeat_message('boosts_expired')) {
                    $self->empire->send_predefined_message(
                        tags        => ['Alert'],
                        filename    => 'boosts_expired.txt',
                        repeat_check=> 'boosts_expired',
                    );
                }
                $self->boost_enabled(0);
            }
        }
    }

    $self->tick_to($now);

    # advance tutorial
    if ($self->empire and $self->empire->tutorial_stage ne 'turing') {
        KA::Tutorial->new(empire=>$self->empire)->finish;
    }
    # clear caches
    $self->clear_future_operating_resources;    
    $cache->delete('ticking', $self->id);
}

# Catch up on all ticks until now
sub tick_to {
    my ($self, $now) = @_;

    $self->log->debug("TICK_TO $now");
    my $seconds  = $now->epoch - $self->last_tick->epoch;
    my $tick_rate = $seconds / 3600;
    $self->last_tick($now);
    
    #If we crossed zero happiness, either way, we need to recalc.
    if ($self->get_stored('happiness') < 0) {
        if ($self->unhappy) {
            # Nothing for now...
        }
        else {
            $self->needs_recalc(1);
            $self->unhappy(1);
            $self->unhappy_date($now);
        }
    }
    else {
        if ($self->unhappy) {
            $self->unhappy(0);
            $self->needs_recalc(1);
        }
        $self->needs_recalc(1) if ($self->propaganda_boost > 50);
    }
    if ($self->needs_recalc) {
        $self->recalc_stats;    
    }
    
    # Process excavator sites
    if ( my $arch = $self->archaeology) {
        if ($arch->effective_efficiency == 100 and $arch->effective_level > 0) {
            my $dig_sec = $now->epoch - $arch->last_check->epoch;
            if ($dig_sec >= 3600) {
                my $dig_hours = int($dig_sec/3600);
                my $new_ld = $arch->last_check->add( seconds => ($dig_hours * 3600));
                $dig_hours = 3 if $dig_hours > 3;
                for (1..$dig_hours) {
                    $arch->run_excavators;
                }
                $arch->last_check($new_ld);
                $arch->update;
            }
        }
        else {
            $arch->last_check($now);
        }
    }

    # happiness
    $self->add_happiness(sprintf('%.0f', $self->get_production('happiness') * $tick_rate));
    
    # waste
    if ($self->get_production('waste') < 0 ) { # if it gets negative, spend out of storage
        $self->spend_waste(sprintf('%.0f',abs($self->get_production('waste')) * $tick_rate));
    }
    else {
        $self->add_waste(sprintf('%.0f', $self->get_production('waste') * $tick_rate));
    }
    
    # energy
    if ($self->get_production('energy') < 0 ) { # if it gets negative, spend out of storage
        $self->spend_energy(sprintf('%.0f',abs($self->get_production('energy')) * $tick_rate));
    }
    else {
        $self->add_energy(sprintf('%.0f', $self->get_production('energy') * $tick_rate));
    }
    
    # water
    if ($self->get_production('water') < 0 ) { # if it gets negative, spend out of storage
        $self->spend_water(sprintf('%.0f',abs($self->get_production('water')) * $tick_rate));
    }
    else {
        $self->add_water(sprintf('%.0f', $self->get_production('water') * $tick_rate));
    }
    
    # ore
    my %ore;
    my $ore_produced   = 0;
    foreach my $type (ORE_TYPES) {
        $ore{$type} = sprintf('%.0f', $self->get_production($type) * $tick_rate);
        if ($ore{$type} > 0) {
            $ore_produced += $ore{$type};
        }
    }
    my $ore_consumed = sprintf('%.0f', $self->get_consumption('ore') * $tick_rate);
    if ($ore_produced > 0 and $ore_produced >= $ore_consumed) {
        # then consumption comes out of production
        foreach my $type (ORE_TYPES) {
            if ($ore{$type} > 0) {
                $ore{$type} -= sprintf('%.0f', $ore{$type} * $ore_consumed / $ore_produced);
            }
        }
    }
    else {
        # We are consuming more than we are producing
        # The difference between consumed and produced comes out of storage
        $ore_consumed -= $ore_produced;
        if ($ore_consumed > 0) {
            my $total_ore = $self->get_stored('ore');
            if ($total_ore > 0) {
                my $deduct_ratio = $ore_consumed / $total_ore;
                $deduct_ratio = 1 if $deduct_ratio > 1;
                foreach my $type (ORE_TYPES) {
                    my $type_stored = $self->get_stored($type);
                    $ore{$type} = 0 if $ore{$type} > 0;
                    my $to_deduct = sprintf('%.0f', $type_stored * $deduct_ratio);
                    $self->spend_ore_type($type, $to_deduct);
                    $ore_consumed -= $to_deduct;
                }

            }
            # if we *still* have ore to consume when we have nothing then we are in trouble!
            if ($ore_consumed > 20) {
                # deduct an arbitrary ore-stuff, but allow for rounding (hence the '20')
                $self->spend_ore_type('gold', $ore_consumed, 'complain');
            }
        }
    }
    # Now deal with remaining individual ore stuffs
    foreach my $type (ORE_TYPES) {
        if ($ore{$type} > 0) {
            $self->add_ore_type($type, $ore{$type});
        }
        elsif ($ore{$type} < 0) {
            $self->spend_ore_type($type, abs($ore{$type}));
        }
    }


    # food
    my %food;
    my $food_produced   = 0;
    foreach my $type (FOOD_TYPES) {
        my $food_item = $self->get_production($type) * $tick_rate;
        $food{$type} = sprintf('%.0f', $food_item);
        if ($food_item > 0) {
            $food_produced += $food_item;
        }
    }
    $food_produced = sprintf('%.0f', $food_produced);

    my $food_consumed = sprintf('%.0f', $self->get_consumption('food') * $tick_rate);
    if ($food_produced > 0 and $food_produced >= $food_consumed) {
        # Then consumption just comes out of production
        foreach my $type (FOOD_TYPES) {
            if ($food{$type} > 0) {
                $food{$type} -= $food{$type} * $food_consumed / $food_produced;
                $food{$type} = sprintf('%.0f', $food{$type});
            }
        }
    }
    else {
        # We are consuming more than we are producing
        # The difference between consumed and produced comes out of storage
        $food_consumed -= $food_produced;
        if ($food_consumed > 0) {
            my $total_food = $self->get_stored('food');
            if ($total_food > 0) {
                # 
                my $deduct_ratio = $food_consumed / $total_food;
                $deduct_ratio = 1 if $deduct_ratio > 1;
                foreach my $type (FOOD_TYPES) {
                    my $type_stored = $self->get_stored($type);
                    $food{$type} = 0 if $food{$type} > 0;
                    my $to_deduct = sprintf('%.0f', $type_stored * $deduct_ratio);
                    $self->spend_food_type($type, $to_deduct);
                    $food_consumed -= $to_deduct;
                }
            }
            # if we *still* have food to consume when we have nothing then we are in trouble!
            if ($food_consumed > 20) {
                # deduct an arbitrary food-stuff, but allow for rounding errors (hence the 20)
                $self->spend_food_type('algae', $food_consumed, 'complain');
            }
        }
    }
    # Now deal with remaining individual food stuffs
    foreach my $type (FOOD_TYPES) {
        if ($food{$type} > 0) {
            $self->add_food_type($type, $food{$type});
        }
        elsif ($food{$type} < 0) {
            $self->spend_food_type($type, abs($food{$type}));
        }
    }

    # deal with negative amounts stored
    # and stall/unstall any supply-chains
    my @supply_chains = $self->out_supply_chains->all;

    if ($self->get_stored('water') <= 0) {
        $self->set_stored('water',0);
        $self->toggle_supply_chain(\@supply_chains, 'water', 1)
    }
    else {
        $self->toggle_supply_chain(\@supply_chains, 'water', 0);
    }
    if ($self->get_stored('energy') <= 0) {
        $self->set_stored('energy',0);
        $self->toggle_supply_chain(\@supply_chains, 'energy', 1);
    }
    else {
        $self->toggle_supply_chain(\@supply_chains, 'energy', 0);
    }

    for my $type (FOOD_TYPES, ORE_TYPES) {
        if ($self->get_stored($type) <= 0) {
            $self->set_stored($type, 0);
            $self->toggle_supply_chain(\@supply_chains, $type, 1);
        }
        else {
            $self->toggle_supply_chain(\@supply_chains, $type, 0);
        }
    }
    if ($self->isa('KA::DB::Result::Map::Body::Planet::Station')) {
        my @buildings = grep {
            $_->efficiency == 0
        } @{$self->building_cache};
        foreach my $building (@buildings) {
            $building->downgrade;
        }
    }
    $self->update;
}

# Change the state of a supply chain (stalled/not-stalled)
sub toggle_supply_chain {
    my ($self, $chains_ref, $resource, $stalled) = @_;

    my @chains = grep {$_->stalled != $stalled and $_->resource_type eq $resource } @$chains_ref;

    foreach my $chain (@chains) {
        $chain->stalled($stalled);
        $chain->update;
        $chain->target->needs_recalc(1);
        $chain->target->update;
        $self->needs_recalc(1);
        $self->update;
        my $empire = $self->empire;
        if ($stalled
            and defined $empire 
            and not $empire->check_for_repeat_message('supply_stalled'.$chain->id)) {
            $empire->send_predefined_message(
                filename    => 'stalled_chain.txt',
                params      => [$self->id, $self->name, $chain->resource_type],
                repeat_check=> 'supply_stalled'.$chain->id,
                tags        => ['Complaint','Alert'],
            );
        }
    }
}

# Do we have enough of a resource to spend?
sub can_spend_type {
    my ($self, $type, $value) = @_;

    if ($self->get_stored($type) < $value) {
        confess [1009, "You don't have enough $type in storage."];
    }
    return 1;
}

# Spend $value amount of a resource $type
sub spend_type {
    my ($self, $type, $value) = @_;

    $self->add_stored($type, 0-$value);
    return $self;
}

# Can we add $value more of a $type of resource?
sub can_add_stored {
    my ($self, $type, $value) = @_;

    if ($type ~~ [ORE_TYPES]) {
        $type = 'ore';
    }
    if ($type ~~ [FOOD_TYPES]) {
        $type = 'food';
    }
    my $capacity = $self->get_capacity($type);
    my $stored   = $self->get_stored($type);
    my $available = $capacity - $stored;
    if ($available < $value) {
        confess [1009, "You don't have enough available storage."];
    }
    return 1;
}

# Add $value amount of a resource $type
sub add_stored_limit {
    my ($self, $type, $value) = @_;

    eval {
        $self->can_add_stored($type, $value);
    };
    if ($@) {
        my $empire = $self->empire;
        if (defined $empire 
            && !$empire->skip_resource_warnings 
            && !$empire->check_for_repeat_message('complaint_overflow'.$self->id)) {
            $empire->send_predefined_message(
                filename        => 'complaint_overflow.txt',
                params          => [$type, $self->id, $self->name],
                repeat_check    => 'complaint_overflow'.$self->id,
                tags            => ['Complaint','Alert'],
            );
        }
    }
    $self->add_stored($type, $value);
    return $self;
}

# add a random ore type
sub add_random_ore {
    my ($self, $value) = @_;
    foreach my $type (shuffle ORE_TYPES) {
        next if $self->$type < 100; 
        $self->add_stored($type,$value);
        last;
    }
    return $self;
}

# add a specific $type of ore
sub add_ore_type {
    my ($self, $type, $amount_requested) = @_;

    my $available_storage = $self->get_capacity('ore') - $self->get_stored('ore');
    $available_storage = 0 if ($available_storage < 0);
    my $amount_to_add = ($amount_requested <= $available_storage) ? $amount_requested : $available_storage;
    $self->add_stored($type, $amount_to_add);
    $self->add_stored('ore', $amount_to_add);
    return $self;
}

# spend a specific $type of ore
sub spend_ore_type {
    my ($self, $type, $amount_spent, $complain) = @_;
    my $amount_stored = $self->get_stored($type);
    if ($amount_spent > $amount_stored && $amount_spent > 0) {
        my $difference = $amount_spent - $amount_stored;
        $self->spend_happiness($difference);
        $self->set_stored($type, 0);

        if ($complain &&
            ($difference * 100) / $amount_spent > 5) {
           
            $self->complain_about_lack_of_resources('ore');
        }
    }
    else {
        $self->add_stored($type, 0 - $amount_spent );
    }
    return $self;
}

# Spend proportionally from all ore
sub spend_ore {
    my ($self, $ore_consumed) = @_;

    my $ore_stored = $self->get_stored('ore');

    # spend proportionally and save
    if ($ore_stored) {
        foreach my $type (ORE_TYPES) {
            $self->spend_ore_type($type, sprintf('%.0f', ($ore_consumed * $self->get_stored($type)) / $ore_stored),'complain');
        }
    }
    return $self;
}

sub ore_hour {
    my ($self) = @_;
    my $tally = 0;
    foreach my $ore (ORE_TYPES) {
        $tally += $self->get_production($ore);
    }
    $tally -= $self->get_consumption('ore');
    return $tally;
}

# determine the total food production per hour
sub food_hour {
    my ($self) = @_;
    my $tally = 0;
    foreach my $food (FOOD_TYPES) {
        $tally += $self->get_production($food);
    }
    $tally -= $self->get_consumption('food');
    return $tally;
}

# add to a specific $type of food stored
sub add_food_type {
    my ($self, $type, $amount_requested) = @_;

    my $available_storage = $self->get_capacity('food') - $self->get_stored('food');
    $available_storage = 0 if ($available_storage < 0);
    my $amount_to_add = ($amount_requested <= $available_storage) ? $amount_requested : $available_storage;
    $self->add_stored($type, $amount_to_add );
    $self->add_stored('food', $amount_to_add);

    return $self;
}

# spend from a specific $type of food
sub spend_food_type {
    my ($self, $type, $amount_spent, $complain) = @_;
    my $amount_stored = $self->get_stored($type);
    if ($amount_spent > 0 && $amount_spent > $amount_stored) {
        my $difference = $amount_spent - $amount_stored;
        $self->spend_happiness($difference);
        $self->set_stored($type, 0);

        # Complain about lack of resources if required but avoid rounding errors
        if ($complain &&
            ($difference * 100) / $amount_spent > 5) {

            $self->complain_about_lack_of_resources('food');
        }
    }
    else {
        $self->add_stored($type, 0 - $amount_spent );
    }
    return $self;
}

# Spend proportionally from all foods
sub spend_food {
    my ($self, $food_consumed, $loss) = @_;
    
    $loss = 0 unless defined($loss);
    # take inventory
    my $food_stored;
    my $food_type_count = 0;
    foreach my $type (FOOD_TYPES) {
        my $stored = $self->get_stored($type);
        $food_stored += $stored;
        $food_type_count++ if ($stored);
    }
    
    # spend proportionally and save
    if ($food_stored) {
        foreach my $type (FOOD_TYPES) {
            # We 'complain' about lack of food if we are spending out of generic food
            # we don't complain about specific foods, because we can always substitute.
            $self->spend_food_type($type, sprintf('%.0f', ($food_consumed * $self->get_stored($type)) / $food_stored),'complain');
        }
    }
    
    # adjust happiness based on food diversity
    unless ($loss or $self->isa('KA::DB::Result::Map::Body::Planet::Station')) {
        if ($food_type_count > 3) {
            $self->add_happiness($food_consumed);
        }
        elsif ($food_type_count < 3) {
            $self->spend_happiness($food_consumed);
            my $empire = $self->empire;
            if (!$empire->skip_resource_warnings && $empire->university_level > 2 && !$empire->check_for_repeat_message('complaint_food_diversity'.$self->id)) {
                $empire->send_predefined_message(
                    filename    => 'complaint_food_diversity.txt',
                    params      => [$self->id, $self->name],
                    repeat_check=> 'complaint_food_diversity'.$self->id,
                    tags        => ['Complaint','Alert'],
                );
            }
        }
    }
    return $self;
}

# add to energy stored
sub add_energy {
    my ($self, $value) = @_;

    my $store = $self->get_stored('energy') + $value;
    my $storage = $self->get_capacity('energy');
    $self->set_stored('energy', ($store < $storage) ? $store : $storage );
    return $self;
}

# spend from energy reserve
sub spend_energy {
    my ($self, $amount_spent) = @_;

    my $amount_stored = $self->get_stored('energy');
    if ($amount_spent > $amount_stored) {
        $self->spend_happiness($amount_spent - $amount_stored);
        $self->set_stored('energy',0);
        $self->complain_about_lack_of_resources('energy');
    }
    else {
        $self->set_stored('energy', $amount_stored - $amount_spent );
    }
    return $self;
}

# add to water stored
sub add_water {
    my ($self, $value) = @_;

    my $store = $self->get_stored('water') + $value;
    my $storage = $self->get_capacity('water');
    $self->set_stored('water', ($store < $storage) ? $store : $storage );
    return $self;
}

# spend from water reserve
sub spend_water {
    my ($self, $amount_spent) = @_;

    my $amount_stored = $self->get_stored('water');
    if ($amount_spent > $amount_stored) {
        $self->spend_happiness($amount_spent - $amount_stored);
        $self->set_stored('water',0);
        $self->complain_about_lack_of_resources('water');
    }
    else {
        $self->set_stored('water', $amount_stored - $amount_spent );
    }
    return $self;
}

# increase the amount of happiness
sub add_happiness {
    my ($self, $value) = @_;

    my $new = $self->get_stored('happiness') + $value;
    if ($new < 0 && $self->empire->is_isolationist) {
        $new = 0;
    }
    $self->set_stored('happiness', $new);
    return $self;
}

# decrease the amount of happiness
sub spend_happiness {
    my ($self, $value) = @_;
    $self->tick;
    
    my $new = $self->get_stored('happiness') - $value;
    my $empire = $self->empire;
    if ($empire and $new < 0) {
        if ($empire->is_isolationist) {
            $new = 0;
        }
        elsif (!$empire->skip_happiness_warnings && !$empire->check_for_repeat_message('complaint_unhappy'.$self->id)) {
            $empire->send_predefined_message(
                filename    => 'complaint_unhappy.txt',
                params      => [$self->id, $self->name],
                repeat_check=> 'complaint_unhappy'.$self->id,
                tags        => ['Complaint','Alert'],
            );
        }
    }
    $self->set_stored('happiness', $new);
    return $self;
}

# add to the amount of waste stored
sub add_waste {
    my ($self, $value) = @_;

    my $store = $self->get_stored('waste') + $value;
    my $storage = $self->get_capacity('waste');
    if ($store < $storage) {
        $self->set_stored('waste', $store );
    }
    else {
        my $empire = $self->empire;
        return $self unless $empire;
        $self->set_stored('waste', $storage );
        $self->spend_happiness( $store - $storage ); # pollution
        if (!$empire->skip_pollution_warnings && $empire->university_level > 2 && !$empire->check_for_repeat_message('complaint_pollution'.$self->id)) {
            $empire->send_predefined_message(
                filename    => 'complaint_pollution.txt',
                params      => [$self->id, $self->name],
                repeat_check=> 'complaint_pollution'.$self->id,
                tags        => ['Complaint','Alert'],
            );
        }
    }
    return $self;
}

# reduce the amount of waste
# if waste goes negative, strip waste using buildings
sub spend_waste {
    my ($self, $value) = @_;
    if ($self->get_stored('waste') >= $value) {
        $self->set_stored('waste', $self->get_stored('waste') - $value );
    }
    else { # if they run out of waste in storage, then the citizens start bitching
        $self->spend_happiness($value - $self->get_stored('waste'));
        $self->set_stored('waste',0);
        my $empire = $self->empire;
        if (!KA->cache->get('lack_of_waste',$self->id)) {
            my $building_name;
            KA->cache->set('lack_of_waste',$self->id, 1, 60 * 60 * 2);
            foreach my $class (qw(KA::DB::Result::Building::Energy::Waste KA::DB::Result::Building::Waste::Treatment KA::DB::Result::Building::Waste::Digester KA::DB::Result::Building::Water::Reclamation KA::DB::Result::Building::Waste::Exchanger)) {
                my ($building) = grep {$_->efficiency > 0} $self->get_buildings_of_class($class);
                if (defined $building) {
                    $building_name = $building->name;
                    $building->spend_efficiency(25)->update;
                    last;
                }
            }
            if ($building_name && !$empire->skip_resource_warnings && !$empire->check_for_repeat_message('complaint_lack_of_waste'.$self->id)) {
                $empire->send_predefined_message(
                    filename    => 'complaint_lack_of_waste.txt',
                    params      => [$building_name, $self->id, $self->name, $building_name],
                    repeat_check=> 'complaint_lack_of_waste'.$self->id,
                    tags        => ['Complaint','Alert'],
                );
            }
        }
    }
    return $self;
}

# the title says it all
sub complain_about_lack_of_resources {
    my ($self, $resource) = @_;
    my $empire = $self->empire;
    # if they run out of resources in storage, then the citizens start bitching
    if (!KA->cache->get('lack_of_'.$resource,$self->id)) {
        my $building_name;
        KA->cache->set('lack_of_'.$resource,$self->id, 1, 60 * 60 * 2);
        if ($self->isa('KA::DB::Result::Map::Body::Planet::Station')) {
            foreach my $building ( sort {
                                          $b->effective_level <=> $a->effective_level ||
                                          $b->efficiency <=> $a->efficiency ||
                                          rand() <=> rand()
                                        }
                                   grep {
                                       $_->class ne 'KA::DB::Result::Building::DeployedBleeder' and
                                       $_->class ne 'KA::DB::Result::Building::Permanent::Crater'
                                   }
                                   @{$self->building_cache} ) {
                if ($building->class eq 'KA::DB::Result::Building::Module::Parliament' || $building->class eq 'KA::DB::Result::Building::Module::StationCommand') {
                    my $others = grep {
                        $_->class ne 'KA::DB::Result::Building::Module::Parliament' and
                        $_->class ne 'KA::DB::Result::Building::Module::StationCommand'
                    } @{$self->building_cache};
                    if ($others) {
                        # If there are other buildings, divert power from them to keep Parliament and Station Command running as long as possible
                        next;
                    }
                    else {
                        my $par = $self->get_building_of_class('KA::DB::Result::Building::Module::Parliament');
                        my $sc = $self->get_building_of_class('KA::DB::Result::Building::Module::StationCommand');
                        if ($sc && $par) {
                            if ($sc->level == $par->level) {
                                if ($sc->level == 1 && $sc->efficiency <= 50 && $par->efficiency <= 50) {
                                    # They go out together with a big bang
                                    $building_name = $par->name;
                                    eval { $sc->spend_efficiency(60) };
                                    eval { $par->spend_efficiency(60) };
                                    last;
                                }
                                elsif ($sc->efficiency <= $par->efficiency) {
                                    $building_name = $par->name;
                                    eval { $par->spend_efficiency(50)->update };
                                    last;
                                }
                                else {
                                    $building_name = $sc->name;
                                    eval {$sc->spend_efficiency(50)->update };
                                    last;
                                }
                            }
                            elsif ($sc->level < $par->level) {
                                $building_name = $par->name;
                                eval {$par->spend_efficiency(50)->update };
                                last;
                            }
                            else {
                                $building_name = $sc->name;
                                eval {$sc->spend_efficiency(50)->update };
                                last;
                            }
                        }
                        elsif ($sc) {
                            $building_name = $sc->name;
                            eval { $sc->spend_efficiency(50)->update };
                            last;
                        }
                        elsif ($par) {
                            $building_name = $par->name;
                            eval { $par->spend_efficiency(50)->update };
                            last;
                        }
                    }
                }
                else {
                    next if ($building->class eq 'KA::DB::Result::Building::Permanent::Crater' or
                             $building->class eq 'KA::DB::Result::Building::DeployedBleeder');
                    $building_name = $building->name;
                    eval { $building->spend_efficiency(50)->update };
                    last;
                }
            }
        }
        else {
             my $class;
            foreach my $rpcclass (shuffle (BUILDABLE_CLASSES)) {
                $class = $rpcclass->model_class;
                next unless ('Infrastructure' ~~ [$class->build_tags]);
            }
            my ($building) = grep {$_->efficiency > 0} $self->get_buildings_of_class($class);
            if (defined $building) {
                $building_name = $building->name;
                $building->spend_efficiency(25)->update;
            }
        }
        if ($building_name && !$empire->skip_resource_warnings && !$empire->check_for_repeat_message('lack_of_'.$resource.$self->id)) {
            $empire->send_predefined_message(
                filename    => 'complaint_lack_of_'.$resource.'.txt',
                params      => [$self->id, $self->name, $building_name],
                repeat_check=> 'complaint_lack_of_'.$resource.$self->id,
                tags        => ['Complaint','Alert'],
            );
        }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

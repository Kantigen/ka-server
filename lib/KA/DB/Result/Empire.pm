package KA::DB::Result::Empire;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use DateTime;
use Scalar::Util qw(weaken);
use List::Util qw(shuffle);
use KA::Util qw(format_date);
use Digest::SHA;
use List::MoreUtils qw(uniq);
use Email::Stuff;
use Email::Valid;
use UUID::Tiny ':std';
use KA::Constants qw(INFLATION_S INFLATION_F);
use PerlX::Maybe qw(provided maybe);
use Log::Any qw($log);
use Data::Dumper;
use KA::SDB;

__PACKAGE__->table('empire');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    stage                   => { data_type => 'varchar', size => 30, is_nullable => 0, default_value => 'new' },
    date_created            => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    self_destruct_date      => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    self_destruct_active    => { data_type => 'tinyint', is_nullable => 0, default_value => 0},
    description             => { data_type => 'text', is_nullable => 1 },
    notes                   => { data_type => 'text', is_nullable => 1 },
    home_planet_id          => { data_type => 'int',  is_nullable => 1 },
    status_message          => { data_type => 'varchar', size => 255 },
    password                => { data_type => 'char', size => 43 },
    sitter_password         => { data_type => 'varchar', size => 30 },
    email                   => { data_type => 'varchar', size => 255, is_nullable => 1 },
    city                    => { data_type => 'varchar', size => 100, is_nullable => 1 },
    country                 => { data_type => 'varchar', size => 100, is_nullable => 1 },
    skype                   => { data_type => 'varchar', size => 100, is_nullable => 1 },
    player_name             => { data_type => 'varchar', size => 100, is_nullable => 1 },
    password_recovery_key   => { data_type => 'varchar', size => 36, is_nullable => 1 },
    last_login              => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    essentia_free           => { data_type => 'float', size => [11,1], default_value => 0 },
    essentia_game           => { data_type => 'float', size => [11,1], default_value => 0 },
    essentia_paid           => { data_type => 'float', size => [11,1], default_value => 0 },
    university_level        => { data_type => 'tinyint', default_value => 0 },
    tutorial_stage          => { data_type => 'varchar', size => 30, is_nullable => 0, default_value => 'explore_the_ui' },
    tutorial_scratch        => { data_type => 'text', is_nullable => 1 },
    is_isolationist         => { data_type => 'tinyint', default_value => 1 },
    storage_boost           => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    food_boost              => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    water_boost             => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    ore_boost               => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    energy_boost            => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    happiness_boost         => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    building_boost          => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    spy_training_boost      => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    facebook_uid            => { data_type => 'bigint', is_nullable => 1 },
    facebook_token          => { data_type => 'varchar', size => 100, is_nullable => 1 },
    alliance_id             => { data_type => 'int', is_nullable => 1 },
    species_name            => { data_type => 'varchar', size => 30, default_value => 'Human', is_nullable => 0 },
    species_description     => { data_type => 'text', is_nullable => 1 },
    min_orbit               => { data_type => 'tinyint', default_value => 3 },
    max_orbit               => { data_type => 'tinyint', default_value => 3 },
    manufacturing_affinity  => { data_type => 'tinyint', default_value => 4 }, # cost of building new stuff
    deception_affinity      => { data_type => 'tinyint', default_value => 4 }, # spying ability
    research_affinity       => { data_type => 'tinyint', default_value => 4 }, # cost of upgrading
    management_affinity     => { data_type => 'tinyint', default_value => 4 }, # speed to build
    farming_affinity        => { data_type => 'tinyint', default_value => 4 }, # food
    mining_affinity         => { data_type => 'tinyint', default_value => 4 }, # minerals
    science_affinity        => { data_type => 'tinyint', default_value => 4 }, # energy, propultion, and other tech
    environmental_affinity  => { data_type => 'tinyint', default_value => 4 }, # waste and water
    political_affinity      => { data_type => 'tinyint', default_value => 4 }, # happiness
    trade_affinity          => { data_type => 'tinyint', default_value => 4 }, # speed of cargoships, and amount of cargo hauled
    growth_affinity         => { data_type => 'tinyint', default_value => 4 }, # planetary command center start level and next colony cost
    skip_medal_messages     => { data_type => 'tinyint', default_value => 0 },
    skip_pollution_warnings => { data_type => 'tinyint', default_value => 0 },
    skip_resource_warnings  => { data_type => 'tinyint', default_value => 0 },
    skip_happiness_warnings => { data_type => 'tinyint', default_value => 0 },
    skip_facebook_wall_posts => { data_type => 'tinyint', default_value => 0 },
    is_admin                => { data_type => 'tinyint', default_value => 0 },
    is_mission_curator      => { data_type => 'tinyint', default_value => 0 },
    skip_found_nothing      => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_resources => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_glyph    => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_plan     => { data_type => 'tinyint', default_value => 0 },
    skip_spy_recovery       => { data_type => 'tinyint', default_value => 0 },
    skip_probe_detected     => { data_type => 'tinyint', default_value => 0 },
    skip_attack_messages    => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_artifact => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_destroyed => { data_type => 'tinyint', default_value => 0 },
    skip_excavator_replace_msg => { data_type => 'tinyint', default_value => 0 },
    dont_replace_excavator  => { data_type => 'tinyint', default_value => 0 },
    latest_message_id       => { data_type => 'int',  is_nullable => 1},
    skip_incoming_ships     => { data_type => 'tinyint', default_value => 0 },
    chat_admin              => { data_type => 'int', default_value => 0 },
    in_stasis               => { data_type => 'tinyint', default_value => 0 },
    timeout                 => { data_type => 'tinyint', default_value => 0 },
    outlaw                  => { data_type => 'tinyint', default_value => 0 },
    outlaw_date             => { data_type => 'datetime', is_nullable => 0, default_value => "2010-10-03 18:17:26" },
);

# tell DBIC that this is unique so it can be sorted properly when dealing
# with has_many, prefetch, and order_by
__PACKAGE__->add_unique_constraint(name => ['name']);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_self_destruct', fields => ['self_destruct_active','self_destruct_date']);
    $sqlt_table->add_index(name => 'idx_password_recovery_key', fields => ['password_recovery_key']);
    $sqlt_table->add_index(name => 'idx_inactives', fields => ['last_login,','self_destruct_active']);
    $sqlt_table->add_index(name => 'idx_admins', fields => ['name,','is_admin']);
}


__PACKAGE__->belongs_to('alliance',         'KA::DB::Result::Alliance',     'alliance_id', { on_delete => 'set null' });
__PACKAGE__->belongs_to('home_planet',      'KA::DB::Result::Map::Body',    'home_planet_id');
__PACKAGE__->belongs_to('latest_message',   'KA::DB::Result::Message',      'latest_message_id', { on_delete => 'set null' });

__PACKAGE__->has_many('spies',              'KA::DB::Result::Spy',          'empire_id');
__PACKAGE__->has_many('planets',            'KA::DB::Result::Map::Body',    'empire_id');
__PACKAGE__->has_many('propositions',       'KA::DB::Result::Proposition',  'proposed_by_id');
__PACKAGE__->has_many('votes',              'KA::DB::Result::Vote',         'empire_id');
__PACKAGE__->has_many('taxes',              'KA::DB::Result::Tax',          'empire_id');
__PACKAGE__->has_many('sent_messages',      'KA::DB::Result::Message',      'from_id');
__PACKAGE__->has_many('received_messages',  'KA::DB::Result::Message',      'to_id');
__PACKAGE__->has_many('medals',             'KA::DB::Result::Medal',        'empire_id');
__PACKAGE__->has_many('all_probes',         'KA::DB::Result::Probe',        'empire_id');
__PACKAGE__->has_many('bodies',             'KA::DB::Result::Map::Body',    'empire_id');

has has_new_messages => (
                         is => 'ro',
                         isa => 'Int',
                         lazy_build => 1,
                        );

sub _build_has_new_messages {
    my ($self) = @_;
    $self->received_messages->search({has_read => 0})->count;
}

has db => (
    is          => 'ro',
    lazy_build  => 1,
);

sub _build_db {
    my ($self) = @_;

    return KA::SDB->instance->db;
}


# I'm the sitter for these babies.
__PACKAGE__->has_many('allbabyauths', 'KA::DB::Result::SitterAuth', 'sitter_id');
__PACKAGE__->has_many('babyauths',    'KA::DB::Result::SitterAuth', sub {
                            my $args = shift;
                            return (
                                    {
                                        "$args->{foreign_alias}.sitter_id" => { -ident => "$args->{self_alias}.id" },
                                        "$args->{foreign_alias}.expiry"    => { '>=' => \q[UTC_TIMESTAMP()] },
                                    },
                                    $args->{self_rowobj} && {
                                        "$args->{foreign_alias}.sitter_id" => $args->{self_rowobj}->id,
                                        "$args->{foreign_alias}.expiry"    => { '>=' => \q[UTC_TIMESTAMP()] },
                                    }
                                   );
                        });

# I'm the baby for these sitters.
__PACKAGE__->has_many('allsitterauths', 'KA::DB::Result::SitterAuth', 'baby_id');
__PACKAGE__->has_many('sitterauths',    'KA::DB::Result::SitterAuth', sub {
                            my $args = shift;
                            return (
                                    {
                                        "$args->{foreign_alias}.baby_id" => { -ident => "$args->{self_alias}.id" },
                                        "$args->{foreign_alias}.expiry"    => { '>=' => \q[UTC_TIMESTAMP()] },
                                    },
                                    $args->{self_rowobj} && {
                                        "$args->{foreign_alias}.baby_id" => $args->{self_rowobj}->id,
                                        "$args->{foreign_alias}.expiry"    => { '>=' => \q[UTC_TIMESTAMP()] },
                                    }
                                   );
                        });

__PACKAGE__->many_to_many('babies', 'babyauths', 'baby');
__PACKAGE__->many_to_many('sitters', 'sitterauths', 'sitter');

for my $affin (qw(
    manufacturing_affinity
    deception_affinity
    research_affinity
    management_affinity
    farming_affinity
    mining_affinity
    science_affinity
    environmental_affinity
    political_affinity
    trade_affinity
    growth_affinity
    )) 
{
    my $builder = "_build_effective_$affin";
    my $clearer = "clear_effective_$affin";
    has "effective_$affin" =>
        is   => 'rw',
        isa  => 'Int',
        lazy => 1,
        builder => $builder,
        clearer => $clearer;

    __PACKAGE__->meta->add_method($builder => sub {
        my $self = shift;

        # for future work, we may allow temporary affinity boosts/penalties.
        return $self->$affin;
    });

    around $affin => sub {
        my ($orig, $self) = (shift, shift);
        if (@_)
        {
            # if we're setting the affinity, clear the effective affinity
            # to force a recalc of the affinity.
            $self->$orig(@_);
            $self->$clearer();
        }
        else
        {
            $self->$orig;
        }
    };
}

has is_active => (
                  is  => 'ro',
                  isa => 'Bool',
                  lazy_build => 1,
                 );

sub _build_is_active {
    my ($self) = @_;
    KA::Cache->instance->get('empire_active', $self->id);
}

sub set_active {
    my ($self) = @_;
    KA::Cache->instance->set('empire_active', $self->id, 1, 30 * 60);
    $self->clear_is_active;
}

sub observatory_probes {
    my ($self,$args) = @_;

    $args = {} unless defined $args;
    $args->{virtual} = 0;
    return $self->all_probes->search($args);
}

sub oracle_probes {
    my ($self,$args) = @_;

    $args = {} unless defined $args;
    $args->{virtual} = 1;
    return $self->all_probes->search($args);
}

sub self_destruct_date_formatted {
    my $self = shift;
    return format_date($self->self_destruct_date);
}

has current_session => (
    is                  => 'rw',
    predicate           => 'has_current_session',
);

sub essentia {
    my ($self, $amount) = @_;

    if (defined $amount) {
        die "Cannot set essentia";
    }
    return $self->essentia_free + $self->essentia_game + $self->essentia_paid;
}

around name => sub {
    my ($orig, $self) = (shift, shift);
    
    if (@_) {
        my $new_name = $_[0];
        
        $self->db->resultset('Log::EmpireNameChange')->new({
            empire_id       => $self->id,
            empire_name     => $new_name,
            old_empire_name => $self->$orig,
        })->insert;
    }
    
    $self->$orig(@_);
};

around update => sub {
    my ($orig, $self) = (shift, shift);
    
    if ( @_ && exists $_[0]->{name} ) {
        $self->db->resultset('Log::EmpireNameChange')->new({
            empire_id       => $self->id,
            empire_name     => $_[0]->{name},
            old_empire_name => $self->name,
        })->insert;
    }
    
    $self->$orig(@_);
};

# Return all allies (including ones-self)
sub allies {
    my ($self) = @_;

    if ($self->alliance_id) {
        my @all = $self->alliance->members->all;
        return @all;
    }
    return ($self);
}

sub update_species {
    my ($self, $me) = @_;

    $self->species_name($me->{name});
    $self->species_description($me->{description});
    $self->min_orbit($me->{min_orbit});
    $self->max_orbit($me->{max_orbit});
    $self->manufacturing_affinity($me->{manufacturing_affinity});
    $self->deception_affinity($me->{deception_affinity});
    $self->research_affinity($me->{research_affinity});
    $self->management_affinity($me->{management_affinity});
    $self->farming_affinity($me->{farming_affinity});
    $self->mining_affinity($me->{mining_affinity});
    $self->science_affinity($me->{science_affinity});
    $self->environmental_affinity($me->{environmental_affinity});
    $self->political_affinity($me->{political_affinity});
    $self->trade_affinity($me->{trade_affinity});
    $self->growth_affinity($me->{growth_affinity});
    return $self;
}

sub determine_species_limits {
    my ($self) = @_;
    my @colony_ids = $self->planets->get_column('id')->all;
    my $colonies = $self->db->resultset('Map::Body')->search({ empire_id => $self->id, class => { '!=' => 'KA::DB::Result::Map::Body::Planet::Station'} });
    my $min_orbit = $colonies->get_column('orbit')->min;
    my $max_orbit = $colonies->get_column('orbit')->max;
    $max_orbit    = 7 if $max_orbit > 7;

    my $reason;
    if ($self->university_level > 19 and $self->university_level != 30) {
        $reason = 'Your university research level is too high to redefine your species. Build a Genetics Lab instead.';
    }
    elsif (KA::Cache->instance->get('redefine_species_timeout', $self->id)) {
        $reason = 'You have already redefined your species in the past 30 days.';
    }
    return {
        essentia_cost   => 100,
        min_growth      => 1, # no longer limited as of 2.4400
        min_orbit       => $min_orbit,
        max_orbit       => $max_orbit,
        can             => ($reason) ? 0 : 1,
        reason          => $reason,
    };
}

sub get_species_stats {
    my $self = shift;
    return {
        name                    => $self->species_name,
        description             => $self->species_description,
        min_orbit               => $self->min_orbit,
        max_orbit               => $self->max_orbit,
        manufacturing_affinity  => $self->manufacturing_affinity,
        deception_affinity      => $self->deception_affinity,
        research_affinity       => $self->research_affinity,
        management_affinity     => $self->management_affinity,
        farming_affinity        => $self->farming_affinity,
        mining_affinity         => $self->mining_affinity,
        science_affinity        => $self->science_affinity,
        environmental_affinity  => $self->environmental_affinity,
        political_affinity      => $self->political_affinity,
        trade_affinity          => $self->trade_affinity,
        growth_affinity         => $self->growth_affinity,
    };
}

sub has_medal {
    my ($self, $type) = @_;
    return $self->db->resultset('Medal')->search({empire_id => $self->id, type => $type})->first;
}

sub add_medal {
    my ($self, $type, $send_message) = @_;
    my $medal = $self->has_medal($type);
    if ($medal) {
        $medal->times_earned( $medal->times_earned + 1);
        $medal->update;
    }
    else {
        $medal = $self->db->resultset('Medal')->new({
            datestamp   => DateTime->now,
            public      => 1,
            empire_id   => $self->id,
            type        => $type,
            times_earned => 1,
        });
        $medal->insert;
        $send_message = 1;
    }
    if ($send_message && !$self->skip_medal_messages) {
        my $name = $medal->name;
        my $image = 'https://d16cbq0l6kkf21.cloudfront.net/assets/medal/'.$type.'.png';
        $self->send_predefined_message(
            tags        => ['Medal'],
            filename    => 'medal.txt',
            params      => [$name, $name, $self->name],
            attachments => {
                image => {
                    title   => $name,
                    url     => $image,
                }
            },
        );
    }
    return $medal;
}

sub spend_essentia {
    my ($self, $args) = @_;

    $args->{amount} *= -1;
    $args->{type} = 'free' unless $args->{type};
    $self->_adjust_essentia($args);
}

sub add_essentia {
    my ($self, $args) = @_;

    $args->{type} = 'game' unless $args->{type};
    $self->_adjust_essentia($args);
}

sub transfer_essentia {
    my ($self, $args) = @_;

    my $type = $self->spend_essentia({
        amount          => $args->{amount},
        reason          => $args->{from_reason},
        other_empire    => $args->{to_empire},
    });
    $self->update;
    my $to_empire = $args->{to_empire};
    $to_empire->add_essentia({
        amount          => $args->{amount},
        reason          => $args->{to_reason},
        type            => $type,
        other_empire    => $self,
    });
    $to_empire->update;
}

sub _adjust_essentia {
    my ($self, $args) = @_;

    my $value           = $args->{amount};
    my $type            = $args->{type} || 'game';
    my $note            = $args->{reason};
    my $transaction_id  = $args->{transaction_id};
    my $other_empire    = $args->{other_empire};
    my $other_id        = $other_empire ? $other_empire->id : 0;
    my $other_name      = $other_empire ? $other_empire->name : '';
    my $return_type;

    $type = "essentia_$type";
    $self->discard_changes;
    if ($value >= 0) {
        # Adding does not matter what type
        $self->$type($self->$type + $value);
        $return_type = $type;
    }
    else {
        # Negative, deduct what we can from the $type
        $return_type = $return_type || $type if $self->$type > 0;
        my $residual = $self->$type + $value;
        if ($residual < 0) {
            $self->$type(0);
            TYPE:
            foreach my $type (qw(essentia_free essentia_game essentia_paid)) {
                # Now deduct from any other types
                $residual = $self->$type + $residual;
                if ($residual >= 0) {
                    $self->$type($residual);
                    last TYPE;
                }
                else {
                    $self->$type(0);
                }
            }
            if ($residual < 0) {
                $self->essentia_free($self->essentia_free + $residual);
            }
        }
        else {
            $self->$type($residual);
        }
    }
    $self->db->resultset('Log::Essentia')->new({
        empire_id       => $self->id,
        empire_name     => $self->name,
        amount          => $value,
        description     => $note,
        transaction_id  => $transaction_id,
        api_key         => (defined $self->current_session) ? $self->current_session->api_key : undef,
        from_id         => $other_id,
        from_name       => $other_name,
    })->insert;

    # Return the type of essentia spent or paid
    $return_type =~ s/essentia_//;
    return $return_type;
}

sub recalc_messages {
    my ($self) = @_;

    # probably don't have to clear it, but shouldn't really hurt, either.
    $self->clear_has_new_messages;
    $self->update({
        latest_message_id   => $self->get_latest_message_id,
    });
}

sub get_new_message_count {
    my ($self) = @_;

    my $count = $self->received_messages->search({
        has_archived    => 0,
        has_read        => 0,
    })->count;

    return $count;
}

sub get_latest_message_id {
    my ($self) = @_;

    my $message = $self->received_messages->search({
        has_archived    => 0,
        has_read        => 0,
        },{
        order_by        => { -desc => 'date_sent' },
    })->first;
    my $message_id = defined $message ? $message->id : undef;
    return $message_id;
}

# The number of times a RPC has been made to this empire
sub rpc_count {
    my $self = shift;
    KA::Cache->instance->get('rpc_count_'.format_date(undef,'%d'), $self->id);
}

sub inc_rpc_count {
    my $self = shift;
    return KA::Cache->instance->incr('rpc_count_'.format_date(undef,'%d'), $self->id, 1, 60 * 60 * 30);
}

# Reseting the RPC count for an empire should be done only under dire
# circumstances, or for testing purposes.  In that case, this can
# encapsulate the arcane magic somewhat.  This should not be exposed via
# the admin UI, but can be called on the server for example as:
# perl -I/home/keno/ka-server/lib -ML -e 'LD->empire(shift)->reset_rpc' 'Jandor Trading'
sub reset_rpc {
    my ($self) = @_;
    my $cache  = KA::Cache->instance;
    my $id     = $self->id;

    printf "RPC count was: %d\n", $cache->get('rpc_count_'.format_date(undef,'%d'), $id);
    printf "RPC rate was: %d\n",  $cache->get('rpc_rate_'.format_date(undef,'%M'), $id);
    $cache->delete('rpc_count_'.format_date(undef,'%d'), $id);
    $cache->delete('rpc_rate_'.format_date(undef,'%M'), $id);
    printf "Reset to zero.";
}

# The number of times the rate limit has been exceeded
has rpc_limit => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return KA::Cache->instance->get('rpc_count_'.format_date(undef,'%d'), $self->id, 1, 60 * 60 * 30);
    }
);

# The one minute RPC rate
has rpc_rate => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return KA::Cache->instance->incr('rpc_rate_'.format_date(undef,'%M'), $self->id, 1, 60 * 2);
    }
);

sub get_status {
    my ($self) = @_;
    my $real_empire = $self->current_session ? $self->current_session->empire : $self;

    my $planet_rs = $real_empire->planets;
    if ($self->alliance_id) {
        $planet_rs = $self->db->resultset('Map::Body')->search({ 
            -or => { 
                'me.empire_id'      => $real_empire->id, 
                'me.alliance_id'    => $real_empire->alliance_id,
            }
        });
    }
    $planet_rs = $planet_rs->search({},{ prefetch => ['empire','star'], order_by => 'me.name' });
    my %planets;
    my %stations;
    my %colonies;
    my %bodies;

    my $gen_body_info = sub {
        my $planet = shift;

        return {
            id          => $planet->id,
            name        => $planet->name,
            zone        => $planet->zone,
            star_id     => $planet->star_id,
            star_name   => $planet->star->name,
            orbit       => $planet->orbit,
            x           => $planet->x,
            y           => $planet->y, #,,,
            empire_name => $planet->empire->name,
            empire_id   => $planet->empire_id,
        }
    };

    while (my $planet = $planet_rs->next) {
        $planets{$planet->id} = $planet->name;
        my $type = 'colonies';
        if ($planet->get_type eq 'space station') {
            $stations{$planet->id} = $planet->name;
            $type = $planet->empire_id == $real_empire->id ? 'mystations' : 'ourstations'
        }
        else {
            $colonies{$planet->id} = $planet->name;
        }

        push @{$bodies{$type}}, $gen_body_info->($planet);
    }

    # shouldn't have to check this once sitter_password goes away.
    if ($self->current_session && !$self->current_session->_is_sitter) {
        $planet_rs = $self->db->resultset('Map::Body')->search({
            'sitterauths.sitter_id' => $real_empire->id,
            'me.class'              => { '!=' => 'KA::DB::Result::Map::Body::Planet::Station' },
        },{
            prefetch => [ 'star', { 'empire', 'sitterauths' } ],
            order_by => ['me.name', 'me.id'],
        });

        while (my $planet = $planet_rs->next) {
            my $empire = $planet->empire;
           
            # I'm not sure if we can get more than one, but getting an error message
            # if that happens will aid in debugging.  If this seems to work consistently,
            # we should remove this block.
            confess [ 999, "Contact an admin / developer: More than one sitterauth is counting? sitter: ".$real_empire->id.", baby: ". $empire->id ]
                unless $empire->sitterauths->count == 1;

            # if we haven't seen this empire yet, put in its basic stats.
            # NOTE: comment out some expensive operations for now
            $bodies{babies}{$empire->name} ||= {
                id                          => $empire->id,
#                has_new_messages            => $empire->has_new_messages,
                sitter_expiry               => format_date($empire->sitterauths->first->expiry),
                maybe alliance_id           => $empire->alliance_id,
#                maybe primary_embassy_id    => $empire->highest_embassy && $empire->highest_embassy->id,
            };
            
            push @{$bodies{babies}{$empire->name}{planets}}, $gen_body_info->($planet);
        }
    }
    my $travelling_ships = $self->db->resultset('Fleet')->search({ 
        type                => { in => [qw(colony_ship short_range_colony_ship)]}, 
        task                => 'travelling', 
        direction           => 'out', 
        'body.empire_id'    => $self->id,
    },{ 
        join => 'body',
    })->count;

    my $status = {
        rpc_count           => 0+$self->rpc_count,
        is_isolationist     => 0+$self->is_isolationist,
        status_message      => $real_empire->status_message,
        name                => $self->name,
        id                  => $self->id,
        essentia            => 0+$self->essentia,
        has_new_messages    => 0+$self->has_new_messages,
        latest_message_id   => 0+$self->latest_message_id,
        home_planet_id      => 0+$self->home_planet_id,
        tech_level          => 0+$self->university_level,
        planets             => \%planets,
        stations            => \%stations,
        colonies            => \%colonies,
        bodies              => \%bodies,
        next_colony_cost    => 0+$self->next_colony_cost("colony_ship",0,$travelling_ships),
        next_colony_srcs    => 0+$self->next_colony_cost("short_range_colony_ship",0,$travelling_ships),
        next_station_cost   => 0+$self->next_colony_cost("space_station"),
        insurrect_value     => 0+$self->next_colony_cost("spy",0,$travelling_ships),
        self_destruct_active=> $self->self_destruct_active,
        self_destruct_date  => $self->self_destruct_date_formatted,
        maybe alliance_id   => $self->alliance_id && 0+$self->alliance_id,
        maybe primary_embassy_id  => $self->highest_embassy && 0+$self->highest_embassy->id,
    };
    return $status;
}

sub start_session {
    my ($self, $options) = @_;
    if (   $options
        && !$options->{is_admin} )
    {
        $self->last_login(DateTime->now);
        $self->update;
    }
    return KA::Session->new->start($self, $options);
}

sub is_password_valid {
    my ($self, $password) = @_;
    return (defined $password && $password ne '' && $self->password eq $self->encrypt_password($password)) ? 1 : 0;
}

sub encrypt_password {
    my ($class, $password) = @_;
    return Digest::SHA::sha256_base64($password);
}

sub set_password {
    my ($self, $password) = @_;
    $self->password($self->encrypt_password($password));
    $self->update;
}

sub attach_invite_code {
    my ($self, $invite_code) = @_;
    my $invites = $self->db->resultset('Invite');
    if (defined $invite_code && $invite_code ne '') {
        my $invite = $invites->search(
            {code    => $invite_code }
        )->first;
        if (defined $invite) {
            if ($invite->invitee_id) {
                $invite = $invite->copy({invitee_id => $self->id, email => $self->email, accept_date => DateTime->now});
            }
            else {
                $invite->invitee_id($self->id);
                $invite->accept_date(DateTime->now);
                $invite->update;
            }
            KA::Cache->instance->incr('friends_accepted', format_date(undef,'%F'), 1, 60 * 60 * 26);
            my $inviter = $invite->inviter;
            if (defined $inviter) { # they may have deleted
                my $accepts = $invites->search({inviter_id => $invite->inviter_id, invitee_id => {'>' => 0}})->count;
                if ($accepts == 3) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Crater',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a crater plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                
                elsif ($accepts == 4) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::RockyOutcrop',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a rocky outcropping plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                
                elsif ($accepts == 5) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Lake',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a lake plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                
                elsif ($accepts == 6) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Sand',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a sand plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                             
                elsif ($accepts == 7) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Grove',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a grove of trees plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                
                elsif ($accepts == 8) { 
                    $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Lagoon',1);
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a lagoon plan'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }                
                elsif ($accepts == 10) { 
                    for my $i (1..13) {
                        $inviter->home_planet->add_plan('KA::DB::Result::Building::Permanent::Beach'.$i,1);
                    }
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'thank_you_for_inviting_friends.txt',
                        params      => [$invite->email, $self->id, $self->name, $accepts, 'a complete set of beach plans'],
                        from        => $self->lacuna_expanse_corp,
                    );
                }
                else {
                    $inviter->send_predefined_message(
                        tags        => ['Correspondence'],
                        filename    => 'friend_joined.txt',
                        params      => [$invite->email, $self->id, $self->name],
                        from        => $self->lacuna_expanse_corp,
                    );
                }
            }
        }
    }
}

sub found {
    my ($self, $home_planet) = @_;

    # lock empire
    $self->update({stage=>'finding home planet'});

    # found home planet
    $home_planet ||= $self->find_home_planet;
    my $current_tutorial_stage = $self->tutorial_stage;
    if ($current_tutorial_stage eq 'explore_the_ui') {
        $self->tutorial_scratch($home_planet->name);
    }
    $self->home_planet_id($home_planet->id);
    $home_planet->size(45);
    # Clean off everything but decor
    my $decor   = [qw(
       KA::DB::Result::Building::Permanent::Beach1
       KA::DB::Result::Building::Permanent::Beach2
       KA::DB::Result::Building::Permanent::Beach3
       KA::DB::Result::Building::Permanent::Beach4
       KA::DB::Result::Building::Permanent::Beach5
       KA::DB::Result::Building::Permanent::Beach6
       KA::DB::Result::Building::Permanent::Beach7
       KA::DB::Result::Building::Permanent::Beach8
       KA::DB::Result::Building::Permanent::Beach9
       KA::DB::Result::Building::Permanent::Beach10
       KA::DB::Result::Building::Permanent::Beach11
       KA::DB::Result::Building::Permanent::Beach12
       KA::DB::Result::Building::Permanent::Beach13
       KA::DB::Result::Building::Permanent::Crater
       KA::DB::Result::Building::Permanent::Grove
       KA::DB::Result::Building::Permanent::Lagoon
       KA::DB::Result::Building::Permanent::Lake
       KA::DB::Result::Building::Permanent::RockyOutcrop
       KA::DB::Result::Building::Permanent::Sand
    )];
    foreach my $building (@{$home_planet->building_cache}) {
        unless ( grep { $building->class eq $_ } @{$decor}) {
            $building->delete;
        }
    }
    $self->stage('founded');
    $self->update;
    $self->home_planet($home_planet);

    $self->add_observatory_probe($home_planet->star_id, $home_planet->id);

    # found colony
    $home_planet->found_colony($self);

    # send welcome
    if ($current_tutorial_stage eq 'explore_the_ui') {
        return KA::Tutorial->new(empire=>$self)->start('explore_the_ui');
    }
    return 1;
}


sub find_home_planet {
    my ($self) = @_;
    my $planets = $self->db->resultset('Map::Body');
    my %body_search = (
        'me.orbit'     => { between => [ $self->min_orbit, $self->max_orbit] },
        'me.empire_id' => undef,
        'me.class'     => { like => 'KA::DB::Result::Map::Body::Planet::P%' }, 
    );
    my %star_search = (
        station_id => undef,
    );
    my $invite = $self->db->resultset('Invite')->search({invitee_id => $self->id})->first;
    my $sz_param = KA->config->get('starter_zone');
    my @stars;
    if (defined $invite) {
        $body_search{'me.zone'} = $invite->zone;
        $star_search{zone} = $invite->zone;
    }
#    elsif ($sz_param and $sz_param->{active}) {
#       if ($sz_param->{zone}) {
#           $body_search{'me.zone'} = { in => $sz_param->{zone_list} };
#           $star_search{zone} = { in => $sz_param->{zone_list} };
#       }
#       if ($sz_param->{coord}) {
#           $body_search{'me.x'} = { between => $sz_param->{x} };
#           $body_search{'me.y'} = { between => $sz_param->{y} };
#           $star_search{x} = { between => $sz_param->{x} };
#           $star_search{y} = { between => $sz_param->{y} };
#       }
#    }
#    else {
#         $body_search{'me.usable_as_starter_enabled'} = 1;
#    }
    @stars  = $self->db->resultset('Map::Star')->search(\%star_search)->get_column('id')->all;
    $body_search{'me.star_id'} = { 'in' => \@stars };
    my @bodies = shuffle $planets->search( \%body_search, { join => 'star' } );
    
    my $home_planet;
    for my $planet (@bodies) {
        next unless (defined $planet);
        next if ($planet->empire);
        next if ($planet->is_claimed);
        next if ($planet->x == -4 && $planet->y == -444); #Unlucky Planet
        next if ($planet->is_locked);
        $planet->lock;
        $home_planet = $planet;
        last;
    }

    # didn't find one
    unless (defined $home_planet) {
        # unlock
        $self->update({stage => 'new'});
        if (defined $invite) {
            $invite->update({invitee_id => undef});
        }
        confess [1002, 'Could not find a home planet. Try again in a few moments.'];
    }
    
    return $home_planet;
}

   
sub get_invite_friend_url {
    my ($self) = @_;
    my $code = create_uuid_as_string(UUID_MD5, $self->id);
    my $invites = $self->db->resultset('Invite');
    my $invite = $invites->search({code => $code})->first;
    unless (defined $invite) {
        $invites->new({
            inviter_id  => $self->id,
            code        => $code,
            zone        => $self->home_planet->zone,
        })->insert;
    }
    return KA->config->get('server_url').'#referral='.$code;
}

sub invite_friend {
    my ($self, $email, $custom_message) = @_;
    $custom_message ||= "I'm having a great time with this new game called KA Expanse. Come play with me.";
    unless (Email::Valid->address($email)) {
        confess [1009, $email.' does not appear to be a valid email address.'];
    }
    my $invites = $self->db->resultset('Invite');
    if ($invites->search({email => $email, inviter_id => $self->id })->count) {
        confess [1009, 'You have already invited '.$email.'.'];
    }
    my $code = create_uuid_as_string(UUID_V4);
    $invites->new({
        inviter_id  => $self->id,
        code        => $code,
        zone        => $self->home_planet->zone,
        email       => $email,
    })->insert;
    KA::Cache->instance->incr('friends_invited', format_date(undef,'%F'), 1, 60 * 60 * 26);
    my $message = sprintf "%s\n\nMy name in the game is %s. Use the code below when you register and you'll be placed near me.\n\n%s\n\n%s\n\nIf you are unfamiliar with The KA Expanse, visit the web site at: http://www.lacunaexpanse.com/",
        $custom_message,
        $self->name,
        $code,
        KA->config->get('server_url').'#referral='.$code;
    Email::Stuff->from($self->email)
        ->to($email)
        ->subject('Come Play With Me')
        ->text_body($message)
        ->send;
}

sub send_email {
    my ($self, $subject, $message) = @_;
    return unless ($self->email);
    Email::Stuff->from('"The KA Expanse" <noreply@lacunaexpanse.com>')
        ->to($self->email)
        ->subject($subject)
        ->text_body($message)
        ->send;
}

sub send_message {
    my ($self, %params) = @_;
    $params{from}   ||= $self;

    my $recipients = $params{recipients};
    unless (ref $recipients eq 'ARRAY' && @{$recipients}) {
        push @{$recipients}, $self->name;
    }
    my $message = $self->db->resultset('Message')->new({
        date_sent   => DateTime->now,
        subject     => $params{subject},
        body        => $params{body},
        tag         => $params{tag} || $params{tags}->[0],
        from_id     => $params{from}->id,
        from_name   => $params{from}->name,
        to_id       => $self->id,
        to_name     => $self->name,
        recipients  => $recipients,
        in_reply_to => $params{in_reply_to},
        repeat_check=> $params{repeat_check},
        attachments => $params{attachments},
    })->insert;
    if (exists $params{repeat_check}) {
        KA::Cache->instance->set($params{repeat_check}, int(DateTime->now->hour / 6), 1, 60 * 60 * 6);
    }
    if (exists $params{in_reply_to} && defined $params{in_reply_to} && $params{in_reply_to} ne '') {
        my $original =  $self->db->resultset('Message')->find($params{in_reply_to});
        if (defined $original && !$original->has_replied) {
            $original->update({has_replied=>1});
        }
    }
    return $message;
}

sub check_for_repeat_message {
    my ($self, $repeat) = @_;
    return KA::Cache->instance->get($repeat, int(DateTime->now->hour / 6));
}

sub send_predefined_message {
    my ($self, %options) = @_;
    my $path = '/home/keno/ka-server/var/messages/'.$options{filename};
    if (open my $file, "<", $path) {
        my $message;
        {
            local $/;
            $message = <$file>;
        }
        close $file;
        unless (ref $options{params} eq 'ARRAY') {
            $options{params} = [];
        }
        my ($subject, $body) = split("~~~\n",sprintf($message, @{$options{params}}));
        chomp $subject;
        if ($options{body_prefix}) {
            $body = $options{body_prefix}.$body;
        }
        return $self->send_message(
            subject     => $subject,
            body        => $body,
            from        => $options{from},
            repeat_check=> $options{repeat_check},
            tags        => $options{tags},
            attachments => $options{attachments},
            );
    }
    else {
        warn "Couldn't send message using $path";
    }
}

sub lacuna_expanse_corp {
    my $self = shift;
    return $self->db->resultset('Empire')->find(1);
}

# Add a 'real' probe. One sent from an observatory.
#
sub add_observatory_probe {
    my ($self, $star_id, $body_id) = @_;

    # add probe
    $self->db->resultset('Probe')->new({
        empire_id   => $self->id,
        star_id     => $star_id,
        body_id     => $body_id,
        alliance_id => $self->alliance_id,
        virtual     => 0,
    })->insert;
    
    # send notifications
    my $star = $self->db->resultset('Map::Star')->find($star_id);
    # Get all empires to be notified that have probes (real or virtual)
    my %to_notify = map { $_->empire_id => 1 } $self->db->resultset('Probe')
                                               ->search_any({
                                                   star_id => $star_id,
                                                   empire_id => {'!=', $self->id }
                                               });
    for my $eid (keys %to_notify) {
        my $that_empire = $self->db->resultset('Empire')->find($eid);
        next unless $that_empire;
        if (!$that_empire->skip_probe_detected) {
            $that_empire->send_predefined_message(
                filename    => 'probe_detected.txt',
                tags        => ['Probe','Alert'],
                from        => $that_empire,
                params      => [$star->x, $star->y, $star->name, $self->id, $self->name],
            );
        }
    }
    
    $self->clear_probed_stars;
    return $self;
}

sub next_colony_cost {
    my ($self, $type, $adjustment, $travelling_ships) = @_;

    $adjustment = 0 unless defined $adjustment;
    my $tally;
    if ($type eq "colony_ship" or $type eq "short_range_colony_ship" or $type eq "spy") {
        my $count = $self->planets->search({ class => { '!=' => 'KA::DB::Result::Map::Body::Planet::Station' }})->count;

        if (not defined $travelling_ships) {
            $travelling_ships = $self->db->resultset('Fleet')->search(
                { type=> { in => [qw(colony_ship short_range_colony_ship)]},
                  task=>'travelling',
                  direction=>'out',
                  'body.empire_id' => $self->id},
                { join => 'body' }
            )->count;
        }
        $count += $travelling_ships + $adjustment;
        my $srcs = $type eq "short_range_colony_ship" ? 25 : 0;
        my $inflation = 1 + INFLATION_F - (($srcs + $self->effective_growth_affinity * 5) / 100);
        $tally = 100_000 * ($inflation**($count-1));
        my $max = 1_350_000_000_000_000 / (1 + (($srcs + $self->effective_growth_affinity * 5) / 100));
        $max *= 200 if $type eq "spy";
        $tally = $max if $tally > $max;
    }
    elsif ($type eq "space_station" and $self->alliance_id) {
        my $count = $self->alliance->stations->count;
        my @allies = $self->db->resultset('Empire')->search(
            {
                alliance_id => $self->alliance_id,
            })->get_column('id')->all;
        $count += $self->db->resultset('Fleet')->search(
            {
                type=> 'space_station',
                task=>'Travelling',
                direction=>'out',
                'body.empire_id' => { in => \@allies}
            },
            { join => 'body' }
        )->count;
        $count += $adjustment;
        my $inflation = 1 + INFLATION_S - (($self->effective_growth_affinity * 15) / 100);
        $tally = 250_000 * ($inflation**($count-1));
        my $max = 300_000_000_000_000 / (1 + ($self->effective_growth_affinity * 5 / 100));
        $tally = $max if $tally > $max;
    }
    else {
        $tally = 10_000_000_000_000_000_000;
    }
    return sprintf('%.0f', $tally);
}

# Get all probes, either observatory or oracle
#
has probed_stars => (
    is          => 'rw',
    clearer     => 'clear_probed_stars',
    lazy        => 1,
    default     => sub {
        my $self = shift;
        my %search = (
            empire_id => $self->id,
        );
        if ($self->alliance_id) {
            %search = (
                alliance_id => $self->alliance_id,
            );
        }
        my @stars = $self->db->resultset('Probe')->search_any(\%search)->get_column('star_id')->all;
        return \@stars;
    },
);

# Get number of probed stars, either observatory or oracle
#
has count_probed_stars => (
    is          => 'rw',
    lazy        => 1,
    default     => sub {    
        my $self = shift;
        return $self->all_probes->count;
    },
);

before delete => sub {
    my ($self) = @_;

    $self->discard_changes;

    $self->votes->delete_all;
    $self->taxes->delete_all;
    $self->propositions->delete_all;
    $self->db->resultset('Invite')->search({ -or => {invitee_id => $self->id, inviter_id => $self->id }})->delete;
    $self->all_probes->delete;
    $self->db->resultset('AllianceInvite')->search({empire_id => $self->id})->delete;
    if ($self->alliance_id) {
        my $alliance = $self->alliance;
        if (defined $alliance) {
            if ( $alliance->leader_id == $self->id) {
                my @members = $alliance->members;
                if (scalar @members == 1) {
                    $alliance->delete;
                }
                else {
                  $alliance->remove_member($self, 1);
                }
            }
            else {
                $alliance->remove_member($self, 1);
            }
        }
    }
    $self->sent_messages->delete;
    $self->received_messages->delete;
    $self->medals->delete;
    $self->allbabyauths->delete;
    $self->allsitterauths->delete;

    my $planets = $self->planets;
    while ( my $planet = $planets->next ) {
        $planet->sanitize if ($planet->empire_id == $self->id); #In case of a cached space station
    }
    my $essentia_log = $self->db->resultset('Log::Essentia');
    my $essentia_code;
    my $config = KA->config;
    my $sum = $self->essentia - $essentia_log->search({empire_id => $self->id, description => 'tutorial' })->get_column('amount')->sum;
    if ($sum > 0 ) {
        $essentia_code = KA::JRC->new->post(
            $config->get('essentia_code_server_url'),
            'add',
            [
                $config->get('server_key'),
                $sum,
                $self->name .' deleted',
            ],
        );
        if ( defined $self->email ) {
            $self->send_email(
                'Essentia Code',
                sprintf("When your account was deleted you had %s essentia remaining. You can redeem it using the code %s on any KA Expanse server.",
                    $sum,
                    $essentia_code,
                ),
            );
        }
        else {
            $self->email('root@localhost');
            $self->send_email(
                'Essentia Code',
                sprintf("When %s's account was deleted it had %s essentia remaining. The essentia code is %s.",
                    $self->name,
                    $sum,
                    $essentia_code,
                ),
            );
        }
    }
    $essentia_log->new({
        empire_id       => $self->id,
        empire_name     => $self->name,
        amount          => $self->essentia * -1,
        description     => 'empire deleted',
        transaction_id  => $essentia_code,
    })->insert;
};

sub enable_self_destruct {
    my $self = shift;
    $self->self_destruct_active(1);
    $self->self_destruct_date(DateTime->now->add(hours => 24));
    $self->update;
    my $subject = 'Your Empire Will Self Destruct In...';
    $self->send_email(
        $subject,
        sprintf("Your empire, %s, will self destruct in 24 hours unless you log in and click on the disable self destruct icon.\n\n%s",
            $self->name,
            KA->config->get('server_url'),
        ),
    );
    $self->send_message(subject => $subject, body => 'Your empire will self destruct in 24 hours unless you click on the disable self destruct icon.');
    return $self;
}

sub disable_self_destruct {
    my $self = shift;
    $self->self_destruct_active(0);
    $self->update;
    return $self;
}

sub redeem_essentia_code {
    my ($self, $code_string) = @_;
    unless (defined $code_string && $code_string ne '') {
        confess [1002,'You must specify an essentia code in order to redeem it.'];
    }
    my $config = KA->config;
    my $amount = KA::JRC->new->post(
        $config->get('essentia_code_server_url'),
        'spend',
        [
            $config->get('server_key'),
            $code_string,
        ],
    );
    $self->add_essentia({
        amount          => $amount, 
        reason          => 'Essentia Code Redemption', 
        transaction_id  => $code_string,
    });
    $self->update;
    return $amount;
}

sub pay_taxes {
    my ($self, $station_id, $amount) = @_;
    my $taxes = $self->db->resultset('Tax')->search({empire_id=>$self->id,station_id=>$station_id})->first;
    if (defined $taxes) {
        $taxes->{paid_0} += $amount;
        $taxes->update;
    }
    else {
        $self->db->resultset('Tax')->new({
            empire_id   => $self->id,
            station_id  => $station_id,
            paid_0      => $amount,
        })->insert;
    }
}

# was being called repeatedly, so move it over to a cached value.
has highest_embassy => (
    is          => 'ro',
    isa         => 'Maybe[KA::DB::Result::Building::Embassy]',
    lazy_build  => 1,
);

sub _build_highest_embassy {
    my ($self) = @_;
    $self->next_highest_embassy;
}

sub next_highest_embassy {
    my ($self, $excluding_body_id) = @_;

    my $search_rs = $self->db->resultset('Building')->search({
        'body.empire_id'    => $self->id,
        'me.class'          => 'KA::DB::Result::Building::Embassy',
        'me.efficiency'     => { '>' => 0 },
    },{
        join                => 'body',
        order_by            => { -desc => 'level' },
    });
    if (defined $excluding_body_id) {
        $search_rs = $search_rs->search({
            body_id         => { "!="  => $excluding_body_id },
        });
    }
    my $embassy = $search_rs->search->first;

    return $embassy;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

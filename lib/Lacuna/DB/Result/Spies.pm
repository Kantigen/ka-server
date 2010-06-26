package Lacuna::DB::Result::Spies;

use Moose;
extends 'Lacuna::DB::Result';
use Lacuna::Util qw(format_date to_seconds);
use DateTime;

__PACKAGE__->table('spies');
__PACKAGE__->add_columns(
    empire_id               => { data_type => 'int', size => 11, is_nullable => 0 },
    name                    => { data_type => 'varchar', size => 30, is_nullable => 0, default_value => 'Agent Null' },
    from_body_id            => { data_type => 'int', size => 11, is_nullable => 0 },
    on_body_id              => { data_type => 'int', size => 11, is_nullable => 0 },
    task                    => { data_type => 'varchar', size => 30, is_nullable => 0, default_value => 'Idle' },
    started_assignment      => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    available_on            => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    offense                 => { data_type => 'int', size => 11, default_value => 1 },
    defense                 => { data_type => 'int', size => 11, default_value => 1 },
    last_mission_score      => { data_type => 'int', size => 11, default_value => 0 },
    date_created            => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    offense_mission_count   => { data_type => 'int', size => 11, default_value => 0 },
    defense_mission_count   => { data_type => 'int', size => 11, default_value => 0 },
    offense_mission_successes => { data_type => 'int', size => 11, default_value => 0 },
    defense_mission_successes => { data_type => 'int', size => 11, default_value => 0 },
    times_captured          => { data_type => 'int', size => 11, default_value => 0 },
    times_turned            => { data_type => 'int', size => 11, default_value => 0 },
    seeds_planted           => { data_type => 'int', size => 11, default_value => 0 },
    spies_killed            => { data_type => 'int', size => 11, default_value => 0 },
    spies_captured          => { data_type => 'int', size => 11, default_value => 0 },
    spies_turned            => { data_type => 'int', size => 11, default_value => 0 },
    things_destroyed        => { data_type => 'int', size => 11, default_value => 0 },
    things_stolen           => { data_type => 'int', size => 11, default_value => 0 },
);

__PACKAGE__->belongs_to('empire', 'Lacuna::DB::Result::Empire', 'empire_id');
__PACKAGE__->belongs_to('from_body', 'Lacuna::DB::Result::Map::Body', 'from_body_id');
__PACKAGE__->belongs_to('on_body', 'Lacuna::DB::Result::Map::Body', 'on_body_id');

sub format_available_on {
    my ($self) = @_;
    return format_date($self->available_on);
}

sub format_started_assignment {
    my ($self) = @_;
    return format_date($self->started_assignment);
}

sub seconds_remaining_on_assignment {
    my $self = shift;
    if ($self->available_on > $self->started_assignment) {
        return to_seconds($self->available_on - $self->started_assignment);
    }
    else {
        return 0;
    }
}

sub is_available {
    my ($self) = @_;
    if (DateTime->now > $self->available_on) {
        my $task = $self->task;
        if ($task ~~ ['Travelling', 'Training', 'Captured','Unconscious']) {
            $self->task('Idle');
            $self->update;
        }
        elsif ($task eq 'Waiting On Trade') {
            my $trade = Lacuna->db->resultset('Lacuna::DB::Result::Trades')->search({
               offer_object_id  => $self->id,
               offer_type       => 'prisoner',
            });
            $trade->withdraw;
        }
        return 1;
    }
    return 0;
}

use constant assignments => (
    'Idle',
    'Counter Espionage',
    'Gather Shipping Intelligence',
    'Gather Empire Intelligence',
    'Gather Operative Intelligence',
    'Hack Network 19',
    'Appropriate Technology',
    'Sabotage Probes',
    'Rescue Comrades',
    'Sabotage Ships',
    'Appropriate Ships',
    'Assassinate Operatives',
    'Sabotage Infrastructure',
    'Incite Mutiny',
    'Incite Rebellion',
);

sub assign {
    my ($self, $assignment) = @_;
    my @assignments = $self->assignments;
    unless ($assignment ~~ @assignments) {
        confess [1009, "You can't assign a spy a task that he's not trained for."];
    }
    unless ($self->is_available) {
        confess [1013, "This spy is unavailable for reassignment."];
    }
    $self->task($assignment);
    $self->started_assignment(DateTime->now);
    return $self;
}

sub level {
    my $self = shift;
    return sprintf('%.0f', ($self->offense + $self->defense) / 200)
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

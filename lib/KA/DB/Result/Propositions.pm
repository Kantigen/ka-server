package KA::DB::Result::Propositions;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use KA::Util qw(format_date);
use DateTime;

__PACKAGE__->load_components('DynamicSubclass');
__PACKAGE__->table('propositions');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    station_id              => { data_type => 'int', size => 11, is_nullable => 0 },
    description             => { data_type => 'text', is_nullable => 1 },
    type                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    scratch                 => { data_type => 'mediumblob', is_nullable => 1, 'serializer_class' => 'JSON' },
    date_ends               => { data_type => 'datetime', is_nullable => 0 },
    proposed_by_id          => { data_type => 'int', size => 11, is_nullable => 0 },
    status                  => { data_type => 'varchar', size => 10, is_nullable => 0, default_value => 'Pending' },
); 

__PACKAGE__->typecast_map(type => {
    AbandonStation          => 'KA::DB::Result::Propositions::AbandonStation',
    BHGNeutralized          => 'KA::DB::Result::Propositions::BHGNeutralized',
    BHGPassport             => 'KA::DB::Result::Propositions::BHGPassport',
    BroadcastOnNetwork19    => 'KA::DB::Result::Propositions::BroadcastOnNetwork19',
    DemolishModule          => 'KA::DB::Result::Propositions::DemolishModule',
    DowngradeModule         => 'KA::DB::Result::Propositions::DowngradeModule',
    EnactWrit               => 'KA::DB::Result::Propositions::EnactWrit',
    ElectNewLeader          => 'KA::DB::Result::Propositions::ElectNewLeader',
    EvictExcavator          => 'KA::DB::Result::Propositions::EvictExcavator',
    EvictMiningPlatform     => 'KA::DB::Result::Propositions::EvictMiningPlatform',
    ExpelMember             => 'KA::DB::Result::Propositions::ExpelMember',
    FireBfg                 => 'KA::DB::Result::Propositions::FireBfg',
    ForeignAid              => 'KA::DB::Result::Propositions::ForeignAid',
    InductMember            => 'KA::DB::Result::Propositions::InductMember',
    InstallModule           => 'KA::DB::Result::Propositions::InstallModule',
    MembersOnlyColonization => 'KA::DB::Result::Propositions::MembersOnlyColonization',
    MembersOnlyStations     => 'KA::DB::Result::Propositions::MembersOnlyStations',
    MembersOnlyExcavation   => 'KA::DB::Result::Propositions::MembersOnlyExcavation',
    MembersOnlyMiningRights => 'KA::DB::Result::Propositions::MembersOnlyMiningRights',
    RenameAsteroid          => 'KA::DB::Result::Propositions::RenameAsteroid',
    RenameStar              => 'KA::DB::Result::Propositions::RenameStar',
    RenameStation           => 'KA::DB::Result::Propositions::RenameStation',
    RenameUninhabited       => 'KA::DB::Result::Propositions::RenameUninhabited',
    RepairModule            => 'KA::DB::Result::Propositions::RepairModule',
    RepealLaw               => 'KA::DB::Result::Propositions::RepealLaw',
    Taxation                => 'KA::DB::Result::Propositions::Taxation',
    TransferStationOwnership=> 'KA::DB::Result::Propositions::TransferStationOwnership',
    UpgradeModule           => 'KA::DB::Result::Propositions::UpgradeModule',
});

__PACKAGE__->belongs_to('proposed_by', 'KA::DB::Result::Empire', 'proposed_by_id');
__PACKAGE__->belongs_to('station', 'KA::DB::Result::Map::Body', 'station_id');
__PACKAGE__->has_many('votes', 'KA::DB::Result::Votes', 'proposition_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_status_date_ends', fields => ['status','date_ends']);
}

has votes_needed => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        int( ($self->station->alliance->members->count + 1) / 2);
    }
);

has votes_yes => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->votes->search({vote => 1})->count;
    }
);

has votes_no => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        $self->votes->search({vote => 0})->count;
    }
);

sub cast_vote {
    my ($self, $empire, $vote) = @_;
    unless ($self->status eq 'Pending') {
        confess [1009, 'This proposition has already '.$self->status.'.'];
    }
    if ($self->votes->search({empire_id => $empire->id})->count) {
        confess [1010, 'You have already voted on this proposition.'];
    }
    KA->db->resultset('KA::DB::Result::Votes')->new({
        proposition_id  => $self->id,
        empire_id       => $empire->id,
        vote            => $vote,
    })->insert;
    $self->check_status;
}

before delete => sub {
    my $self = shift;
    $self->fail if $self->status eq 'Pending';
    $self->votes->delete_all;
};

sub check_status {
    my $self = shift;
    my $cache = KA->cache;

    if ($self->status eq 'Pending') {
        # cache check as close as possible to cache set to reduce chance
        # (but not eliminate chance) of race condition
        if ($self->votes_yes >= $self->votes_needed) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->pass;
        }
        elsif ($self->votes_no >= $self->votes_needed) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->fail;
        }
        elsif ($self->date_ends->epoch < time()) {
            return $self if $cache->get('proposition_recently_completed', $self->id);
            $cache->set('proposition_recently_completed', $self->id, 30);
            $self->time_is_up;
        }
        $self->update;
    }
    return $self;
}

# allow some propositions to auto-fail by overriding this.
sub time_is_up
{
    my ($self) = @_;
    $self->pass;
}

sub pass {
    my $self = shift;
    $self->station->alliance->send_predefined_message(
        filename    => 'parliament_vote_passed.txt',
        tags        => ['Parliament','Correspondence'],
        params      => [
            $self->name,
            $self->name,
            $self->votes_yes,
            $self->votes_no,
            $self->description,
            $self->pass_extra_message,
        ],
    );
    $self->status('Passed');
    return $self;
}

has pass_extra_message => (
    is  => 'rw',
);

sub fail {
    my $self = shift;
    $self->station->alliance->send_predefined_message(
        filename    => 'parliament_vote_failed.txt',
        tags        => ['Parliament','Correspondence'],
        params      => [
            $self->name,
            $self->name,
            $self->votes_yes,
            $self->votes_no,
            $self->description,
            $self->fail_extra_message,
        ],
    );
    $self->status('Failed');
    return $self;
}

has fail_extra_message  => (
    is  => 'ro',
);

before insert => sub {
    my $self = shift;
    $self->date_ends( DateTime->now->add(hours => 72) );
};

after insert => sub {
    my $self = shift;
    $self->send_vote;
};

sub get_status {
    my ($self, $empire) = @_;
    my $out = {
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        votes_needed=> $self->votes_needed,
        votes_yes   => $self->votes_yes,
        votes_no    => $self->votes_no,
        status      => $self->status,
        date_ends   => $self->date_ends_formatted,
        station     => $self->station->name,
        station_id  => $self->station->id,
        proposed_by => {
            id      => $self->proposed_by->id,
            name    => $self->proposed_by->name,
        },
    };
    if (defined $empire) {
        my $vote = $self->votes->search({ empire_id => $empire->id})->first;
        if (defined $vote) {
            $out->{my_vote} = $vote->vote;
        }
    }
    return $out;
}

sub send_vote {
    my $self = shift;
    my $station = $self->station;
    my $parliament = $station->parliament;
    $station->alliance->send_predefined_message(
        filename    => 'parliament_vote.txt',
        tags        => ['Parliament','Correspondence'],
        from        => $self->proposed_by,
        params      => [
            $self->name,
            $self->name,
            $self->description,
            $station->id,
            $parliament->id,
            $self->id,
            $station->id,
            $parliament->id,
            $self->id,
        ],
    );
}

sub date_ends_formatted {
    my ($self) = @_;
    return format_date($self->date_ends);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

package KA::DB::Result::Law;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use KA::Util qw(format_date);
use DateTime;

__PACKAGE__->load_components('DynamicSubclass');
__PACKAGE__->table('law');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    station_id              => { data_type => 'int', size => 11, is_nullable => 0 },
    description             => { data_type => 'text', is_nullable => 1 },
    type                    => { data_type => 'varchar', size => 30, is_nullable => 0 },
    scratch                 => { data_type => 'mediumblob', is_nullable => 1, 'serializer_class' => 'JSON' },
    date_enacted            => { data_type => 'datetime', is_nullable => 0, set_on_create => 1 },
    star_id                 => { data_type => 'int', is_nullable => 1 },
); 

__PACKAGE__->typecast_map(type => {
    BHGNeutralized          => 'KA::DB::Result::Law::BHGNeutralized',
    BHGPassport             => 'KA::DB::Result::Law::BHGPassport',
    MembersOnlyColonization => 'KA::DB::Result::Law::MembersOnlyColonization',
    MembersOnlyStations     => 'KA::DB::Result::Law::MembersOnlyStations',
    MembersOnlyMiningRights => 'KA::DB::Result::Law::MembersOnlyMiningRights',
    MembersOnlyExcavation   => 'KA::DB::Result::Law::MembersOnlyExcavation',
    Taxation                => 'KA::DB::Result::Law::Taxation',
    Writ                    => 'KA::DB::Result::Law::Writ',
});

__PACKAGE__->belongs_to('station', 'KA::DB::Result::Map::Body', 'station_id');
__PACKAGE__->belongs_to('star', 'KA::DB::Result::Map::Star', 'star_id', { on_delete => 'set null' });

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_date_enacted', fields => ['date_enacted']);
}

before delete => sub {
    my $self = shift;
    $self->notify_about_law('parliament_law_repealed.txt');
};

after insert => sub {
    my $self = shift;
    $self->notify_about_law('parliament_law_enacted.txt');
};

sub notify_about_law {
    my ($self, $filename) = @_;
    if ($self->star_id) {
        $self->notify_stellar_inhabitants($self->star, $filename);
    }
    else {
        my $stars = $self->station->stars;
        while (my $star = $stars->next) {
            $self->notify_stellar_inhabitants($star, $filename);
        }
    }
}

sub notify_stellar_inhabitants {
    my ($self, $star, $filename) = @_;
    my $planets = $star->bodies->search({empire_id => {'!=' => undef } });
    my $station = $self->station;
    my $from = $station->alliance->leader;
    while (my $planet = $planets->next) {
        $planet->empire->send_predefined_message(
            filename    => $filename,
            from        => $from,
            params      => [$self->name, $station->name.'('.$station->x.','.$station->y.')', $planet->name, $self->description],
            tags        => ['Parliament','Correspondence'],
        );
    }
}

sub get_status {
    my ($self, $empire) = @_;
    my $out = {
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        date_enacted   => $self->date_enacted_formatted,
    };
    return $out;
}

sub date_enacted_formatted {
    my ($self) = @_;
    return format_date($self->date_enacted);
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

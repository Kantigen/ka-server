package KA::RPC::Alliance;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::RPC';
use KA::Util qw(format_date randint);
use DateTime;
use String::Random qw(random_string);
use UUID::Tiny ':std';
use Time::HiRes;

sub find {
    my $self = shift;
    my $args = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id      => $args,
            name            => shift,
        };
    }
    my $name = $args->{name};

    unless (length($name) >= 3) {
        confess [1009, 'Alliance name too short. Your search must be at least 3 characters.'];
    }
    my $session = $self->get_session($args);
    my $empire = $session->current_empire;
    my $alliances = KA->db->resultset('Alliance')->search({name => {'like' => $name.'%'}}, {rows=>100});
    my @list_of_alliances;
    my $limit = 100;
    while (my $alliance = $alliances->next) {
        push @list_of_alliances, {
            id      => $alliance->id,
            name    => $alliance->name,
        };
        $limit--;
        last unless $limit;
    }
    return { alliances => \@list_of_alliances, status => $self->format_status($session) };
}


sub view_profile {
    my $self = shift;
    my $args = shift;

    if (ref($args) ne "HASH") {
        $args = {
            session_id      => $args,
            alliance_id     => shift,
        };
    }

    my $alliance_id = $args->{alliance_id};
    my $session = $self->get_session($args);
    my $empire = $session->current_empire;
    unless (defined $alliance_id && length $alliance_id) {
        confess [1002, "You must specify an alliance ID."];
    }
    my $alliance = KA->db->resultset('KA::DB::Result::Alliance')->find($alliance_id);
    my $members = $alliance->members;
    my @members_list;
    while (my $member = $members->next) {
        push @members_list, {
            id          => $member->id,
            name        => $member->name,
        };
    }
    my $stations = $alliance->stations;
    my @stations_list;
    my $influence = 0;
    while (my $station = $stations->next) {
        push @stations_list, {
            id          => $station->id,
            name        => $station->name,
            x           => $station->x,
            y           => $station->y,
        };
        $influence += $station->total_influence;
    }
    my %out = (
        id              => $alliance->id,
        name            => $alliance->name,
        description     => $alliance->description,
        date_created    => $alliance->date_created_formatted,
        leader_id       => $alliance->leader_id,
        members         => \@members_list,
        space_stations  => \@stations_list,
        influence       => $influence,
    );
    return { profile => \%out, status => $self->format_status($session) };
}


__PACKAGE__->register_rpc_method_names(qw(
    find
    view_profile
));

no Moose;
__PACKAGE__->meta->make_immutable;


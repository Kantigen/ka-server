package KA::Role::Navigation;

use Moose::Role;

# Find a 'target' based on a number of methods
#
sub find_target {
    my ($self, $target_params) = @_;
    unless (ref $target_params eq 'HASH') {
        confess [-32602, 'The target parameter should be a hash reference. For example { "star_id" : 9999 }.'];
    }
    my $target;
    if (exists $target_params->{star_id}) {
        $target = KA->db->resultset('Map::Star')->find($target_params->{star_id});
    }
    elsif (exists $target_params->{star_name}) {
        $target = KA->db->resultset('Map::Star')->search({ name => $target_params->{star_name} }, {rows=>1})->single;
    }
    if (exists $target_params->{body_id}) {
        $target = KA->db->resultset('Map::Body')->find($target_params->{body_id});
    }
    elsif (exists $target_params->{body_name}) {
        $target = KA->db->resultset('Map::Body')->search({ name => $target_params->{body_name} }, {rows=>1})->single;
    }
    elsif (exists $target_params->{x}) {
        $target = KA->db->resultset('Map::Body')->search({ x => $target_params->{x}, y => $target_params->{y} }, {rows=>1})->single;
        unless (defined $target) {
            $target = KA->db->resultset('Map::Star')->search({ x => $target_params->{x}, y => $target_params->{y} }, {rows=>1})->single;
        }
    }
    unless (defined $target) {
        confess [ 1002, 'Could not find the target.', $target];
    }
    return $target;
}
1;


package KA::ClientCode;

use Moose;
use namespace::autoclean;

use KA::Cache;

use UUID::Tiny ':std';
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

# A unique ID for the client_code key
# 
# If one is not supplied, a valid client code is generated
has id => (
    is      => 'rw',
    lazy    => 1,
    builder => 'create_valid_id',
);

# Namespace to use in cache
#
has namespace => (
    is      => 'rw',
    default => 'client_code',
);

# The Cache object
# 
has cache => (
    is          => 'ro',
    lazy        => 1,
    builder     => '_build_cache',
);

# The 'secret'
#
has secret => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_secret',
);

# How long until the client_code times out due to lack of activity
#
has timeout_sec => (
    is      => 'rw',
    default => 60 * 60 * 2,
);

# Number of times the client_code has been extended
#
has extended => (
    is      => 'rw',
    default => 0,
);

# The ID of the user who is logged in (or previously logged in)
#
has user_id => (
    is          => 'rw',
    predicate   => 'has_user_id',
    default     => 0,
);

# A flag showing if the user is logged in or not
#
has logged_in => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);

#--- Build the secret
#
sub _build_secret {
    my ($self) = @_;
    return KA::Config->instance->get('secret');
}    

#--- Buid the cache
#
sub _build_cache {
    my ($self) = @_;
    return KA::Cache->instance;
}

#--- Automatically extend the client_code if we update any values
#
for my $func (qw(user_id logged_in)) {
    around $func => sub {
        my $orig = shift;
        my $self = shift;

        return $self->$orig() if not @_;
        my $ret = $self->$orig(@_);
        $self->extend;
        return $ret;
    };
}

#--- Build it and auto-expand from the cache if the ID has been specified
#
sub BUILD {
    my ($self,$args) = @_;

    if (defined $self->id) {
        $self->from_hash($self->cache->get_and_deserialize($self->namespace, $self->id));
    }
}


#--- Create a hash of this client_code
#
sub to_hash {
    my ($self) = @_;

    return {
        user_id     => $self->user_id,
        logged_in   => $self->logged_in,
        extended    => $self->extended,
    };
}

#--- Update the object from a hash
#
sub from_hash {
    my ($self, $hash) = @_;

    if (defined $hash and ref $hash eq 'HASH') {
        $self->user_id($hash->{user_id});
        $self->extended($hash->{extended});
        $self->logged_in($hash->{logged_in});
    }
}


#--- extend the client_code timer
# 
sub extend {
    my ($self) = @_;

    $self->extended($self->extended + 1);
    $self->cache->set($self->namespace, $self->id, $self->to_hash, $self->timeout_sec);
}


#--- Create a random Client Code id
#   Add a 'secret' so that people can't invent their own Client Code
#   
sub create_valid_id {
    my ($self) = @_;

    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$self->secret), 0, 6);
    return $uuid."-".$digest;
}

#--- Get a new Client Code id
#
sub get_new_id {
    my ($self) = @_;
    $self->id($self->create_valid_id);
}

#--- Validate the client code
#
sub is_valid {
    my ($self) = @_;

    return if not defined $self->id;

    my $uuid    = substr($self->id, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$self->secret), 0, 6);

    return if $test ne $self->id;

    return 1;
}

# Validate a client_code variable with confess
#
sub assert_valid {
    my ($self) = @_;

    confess [1001, "Client Code is missing"] if not defined $self->id;
    if (not $self->is_valid) {
        confess [1001, "Client Code is invalid! [".$self->id."]" ];
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;


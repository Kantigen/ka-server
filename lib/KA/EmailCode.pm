package KA::EmailCode;

use Moose;
use namespace::autoclean;
use UUID::Tiny ':std';
use KA::Cache;

use Digest::MD5 qw(md5_hex);

# A unique ID for the email_code key
#
has id => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_id',
);

# Namespace to use in cache
#
has namespace => (
    is      => 'rw',
    default => 'email_code',
);

# The Cache object
#
has cache => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_cache',
);

# The 'secret'
#
has secret => (
    is       => 'ro',
    lazy     => 1,
    builder  => '_build_secret',
);

# How long until the email_code times out
#
has timeout_sec => (
    is      => 'rw',
    default => 60 * 60 * 4,
);

# The ID of the User who requested the email code
#
has user_id => (
    is      	=> 'rw',
    isa     	=> 'Int',
    required	=> 1,
);

sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger($self);
}


# Called *after* the object has been constructed
#
sub BUILD {
    my ($self,$args) = @_;

    $self->from_hash($self->cache->get_and_deserialize($self->namespace, $self->id));
    $self->store;
}


# Create a new random id
#   Add a 'secret' so that people can't invent their own email_code
#
sub _build_id {
    my ($self) = @_;
    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$self->secret), 0, 6);
    return $uuid."-".$digest;
}

#--- Build the secret
#
sub _build_secret {
    my ($self) = @_;
    return KA::Config->instance->get('email_secret');
}

#--- Buid the cache
#
sub _build_cache {
    my ($self) = @_;
    return KA::Cache->instance;
}

# Automatically store the email_code if we update any values
#
for my $func (qw(user_id)) {
    around $func => sub {
        my $orig = shift;
        my $self = shift;

        return $self->$orig() if not @_;

        my $ret = $self->$orig(@_);
        $self->store;
        return $ret;
    };
}

# store the email code timer
#
sub store {
    my ($self) = @_;

    $self->cache->set($self->namespace, $self->id, $self->to_hash, $self->timeout_sec);
    return $self;
}

# Create a hash of this email_code
#
sub to_hash {
    my ($self) = @_;

    return {
        user_id     => $self->user_id,
    };
}

# Update the object from a hash
#
sub from_hash {
    my ($self, $hash) = @_;

    if (defined $hash and ref $hash eq 'HASH') {
        $self->user_id($hash->{user_id});
    }
}

# Validate an email code
#
sub validate {
    my ($self) = @_;

    my $log = $self->log;
    return if not defined $self->id;
    my $uuid    = substr($self->id, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$self->secret), 0, 6);
    $log->debug("test = [$test]");
    $log->debug("retn = [".$self->id."]");
    return $test eq $self->id ? $self : undef;
}

# Validate an email code with confess
#
sub assert_valid {
    my ($self) = @_;

    confess [1000, "Email Code is missing" ]            if not defined $self->id;
    confess [1001, "Invalid Email Code", $self->id ]    if not $self->validate;
    return $self;
}

__PACKAGE__->meta->make_immutable;


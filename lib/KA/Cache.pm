package KA::Cache;

use MooseX::Singleton;

use KA::Redis;

use JSON;

use namespace::autoclean;

has 'redis' => (
    is          => 'ro',
    lazy        => 1,
    builder     => '_build_redis',
);

sub _build_redis {
    my ($self) = @_;

    return KA::Redis->instance;
}

# Create a key from 'namespace' and a 'key'
#
sub namespace_key {
    my ($self, $namespace, $id) = @_;

    my $key = join ':', grep defined, $namespace, $id;
    $key =~ s/\s+/_/g;
    return $key;
}

# Delete a key
#
sub delete {
    my ($self, $namespace, $id) = @_;

    my $key = $self->namespace_key($namespace, $id);
    return $self->redis->del($key);
}

# Get a value for a key
#
sub get {
    my ($self, $namespace, $id) = @_;

    my $key = $self->namespace_key($namespace, $id);
    return $self->redis->get($key);
}

# Get a value for a key and deserialize it (JSON)
#
sub get_and_deserialize {
    my ($self, $namespace, $id) = @_;

    my $value = $self->get($namespace, $id);
    if (defined $value) {
        $value = eval {
            JSON::from_json($value);
        };
#        warn $@ if ($@);
        return $value;
    }
    return;
}

# Set a value (with optional timeout)
#
sub set {
    my ($self, $namespace, $id, $value, $expire) = @_;

    my $key             = $self->namespace_key($namespace, $id);
    my $frozen_value    = (ref $value) ? JSON::to_json($value) : $value;
    my $retval = $self->redis->set($key, $frozen_value);
    $self->expire($namespace, $id, $expire) if defined $expire;
    return $retval;
}

# Set an expiry time
#
sub expire {
    my ($self, $namespace, $id, $expire) = @_;

    return unless defined $expire;

    my $key = $self->namespace_key($namespace, $id);
    return $self->redis->expire($key, $expire);
}


# Increment a value
#
sub incr {
    my ($self, $namespace, $id, $amount, $expire) = @_;

    my $key = $self->namespace_key($namespace, $id);
    my $by = $amount || 1;
    my $retval = $self->redis->incrby($key, $by);
    $self->expire($namespace, $id, $expire) if defined $expire;
    return $retval;
}

# Decrement a value
#
sub decr {
    my ($self, $namespace, $id, $amount, $expire) = @_;

    my $key = $self->namespace_key($namespace, $id);
    my $by = $amount || 1;
    my $retval = $self->redis->decrby($key, $by);
    $self->expire($namespace, $id, $expire) if defined $expire;
    return $retval;
}

# Check the Time To Live
#
sub ttl {
    my ($self, $namespace, $id) = @_;

    my $key = $self->namespace_key($namespace, $id);
    return $self->ttl($namespace);
}

# Check if a key exists
#
sub exists {
    my ($self, $namespace, $id) = @_;

    my $key = $self->namespace_key($namespace, $id);
    return $self->exists($key);
}

__PACKAGE__->meta->make_immutable;


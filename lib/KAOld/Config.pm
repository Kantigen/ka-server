package KA::Config;

use MooseX::Singleton;
use namespace::autoclean;

use Config::JSON;

has filename => (
    is          => 'rw',
    isa         => 'Str',
    default    => '/home/keno/ka-server/etc/keno-antigen.conf',
);

has config_json => (
    is          => 'rw',
    isa         => 'Config::JSON',
    handles     => {
        get     => 'get',
    },
    lazy        => 1,
    builder     => '_build_config_json',
);

sub _build_config_json {
    my ($self) = @_;

    return Config::JSON->new($self->filename);
}

__PACKAGE__->meta->make_immutable;


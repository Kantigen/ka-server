package Lacuna::DB::Result::DBVersion;

use Moose;
use namespace::autoclean;
use Crypt::SaltedHash;

use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::DB::Result';

__PACKAGE__->table('db_version');
__PACKAGE__->add_columns(
    major_version           => { data_type => 'integer',    size => 11,     is_nullable => 0    },
    minor_version           => { data_type => 'integer',    size => 11,     is_nullable => 0    },
    description             => { data_type => 'varchar',    size => 255,    is_nullable => 0    },
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


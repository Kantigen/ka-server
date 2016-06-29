package KA::DB::Result::User;

use Moose;
use namespace::autoclean;
use Crypt::SaltedHash;

use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    username                => { data_type => 'varchar',    size => 30,     is_nullable => 0    },
    password                => { data_type => 'char',       size => 45                          },
    email                   => { data_type => 'varchar',    size => 255,    is_nullable => 1    },
    password_recovery_key   => { data_type => 'varchar',    size => 36,     is_nullable => 1    },
    registration_stage      => { data_type => 'varchar',    size => 16,     is_nullable => 1    },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_password_recovery_key', fields => ['password_recovery_key']);
}

# Return the object as a (much smaller) hash
#
sub as_hash {
    my ($self) = @_;

    return {
        id                      => $self->id,
        username                => $self->username,
        email                   => $self->email,
        registration_stage      => $self->registration_stage,
        password_recovery_key   => $self->password_recovery_key,
    };
}


sub check_password {
    my ($self, $password) = @_;

    my $valid = Crypt::SaltedHash->validate($self->password, $password);

    my $csh = Crypt::SaltedHash->new;
    $csh->add($password);
    my $salted = $csh->generate;
    return $valid;
}

# Encrypt the password
# When reading the password, return it as-is (it should already be encrypted in the database)
# when writing the password, encrypt it
#
around password => sub {
    my ($orig, $self) = (shift,shift);

    return $self->$orig() unless @_;

    my $password = shift;
    if ($password =~ m/^{SSHA}/) {
        # it is already encrypted
        return $self->$orig($password);
    }

    # otherwise encrypt it
    my $csh = Crypt::SaltedHash->new;
    $csh->add($password);
    $password = $csh->generate;

    return $self->$orig($password);
};

# Encrypt on insert
# encrypt the password, if it is not already encrypted
#
around insert => sub {
    my ($orig, $self) = (shift,shift);

    if ($self->password =~ m/^{SSHA}/) {
        return $self->$orig(@_);
    }

    $self->password($self->password);
    return $self->$orig(@_);
};


__PACKAGE__->meta->make_immutable(inline_constructor => 0);


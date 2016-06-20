package KA::DB::ResultSet::User;

use Moose;
use namespace::autoclean;
use Data::Validate::Email qw(is_email);
use Crypt::SaltedHash;
use Text::Trim qw(trim);
use Email::Valid;

extends 'KA::DB::ResultSet';

# Assert that a username is available
# throw an error if not
#
sub assert_username_available {
    my ($self, $username) = @_;

    confess [1001, 'Username must be at least 3 characters long' ] if not defined $username;
    trim $username;
    confess [1001, 'Username must be at least 3 characters long', $username] if length($username) < 3;

    my ($row) = $self->search({
        username    => $username,
    });
    confess [1001, 'Username not available', $username] if $row;
    return 1;

}

# Assert that an email address is valid
#
sub assert_email_valid {
    my ($self, $email) = @_;

    confess [1001, 'Email is missing' ]         if not defined $email;
    trim($email);

    $email = Email::Valid->address($email);
    if (not $email or not is_email($email) ) {
        confess [1001, 'Email is invalid', $email];
    }
    return $email;
}

# Assert that an email address is available
#
sub assert_email_available {
    my ($self, $email) = @_;

    $email = $self->assert_email_valid($email);    
    my ($row) = $self->search({
        email       => $email,
    });
    confess [1001, 'Email is not available', $email] if $row;
    return 1;
}

# Assert that a password is valid
#
sub assert_password_valid {
    my ($self, $password) = @_;

    confess [1001, 'Password is missing' ]                                                  if not defined $password;
    trim($password);
    confess [1001, 'Password must be at least 5 characters long', $password ]               if length($password) < 5;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[0-9]/;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[a-z]/;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[A-Z]/;
    return 1;
}

# Assert that everything is correct to create a new User
#
sub assert_create {
    my ($self, $args) = @_;

    $self->assert_username_available($args->{username});
    $self->assert_email_available($args->{email});

    my $csh = Crypt::SaltedHash->new->add($args->{password})->generate;

    my $user = $self->create({
        username    => $args->{username},
        email       => $args->{email},
    });

    confess [1002, 'Could not create new user' ] if not $user;
    
    return $user;
}

# Assert that either the username or the email address is valid
#
sub assert_find_by_username_or_email {
    my ($self, $username_or_email) = @_;

    my ($user) = $self->search({
        -or => [
            username    => $username_or_email,
            email       => $username_or_email,
        ],
    });
    confess [1002, 'Could not find account' ] if not $user;
    return $user;
}           

# Assert that a row exists with a specified id
#
sub assert_id {
    my ($self, $id) = @_;

    my ($user) = $self->search({
        id  => $id,
    });
    confess [1002, 'Could not find account' ] if not $user;
    return $user;
}

# Assert that a user can log in with a password
#
sub assert_login_with_password {
    my ($self, $args) = @_;

    confess [1001, 'username is missing' ]      if not defined $args->{username};
    confess [1001, 'password is missing' ]      if not defined $args->{password};

    my ($user) = $self->search({
        username    => $args->{username},
    });
    confess [1001, 'Incorrect credentials 1']     if not defined $user;
    confess [1001, 'Incorrect credentials 2']     if not $user->check_password($args->{password});

    return $user;
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

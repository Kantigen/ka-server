package UnitTestsFor::KA::WebSocket::User;

use lib "lib";
use lib "t/lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';
use Test::Exception;
use Data::Dumper;
use Log::Log4perl;

use KA::WebSocket::User;
use KA::ClientCode;
use KA::EmailCode;

use UnitTestsFor::Fixtures::WebSocket::User;

sub test_construction {
    my ($self) = @_;

    my $ws_user = KA::WebSocket::User->new;
    isa_ok($ws_user, 'KA::WebSocket::User');
}

sub test_ws_clientCode {
    my ($self) = @_;

    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 123,
    });
    my $ws_user = KA::WebSocket::User->new;

    # An invalid clientCode should return a valid one
    #
    my $response = $ws_user->ws_clientCode($context);

    my $client_code_id = $response->{clientCode};
    isnt($client_code_id,       undef,              "There is a client code");
    isnt($client_code_id,       'invalid',          "Response: clientCode changed");
    my $client_code = KA::ClientCode->new({
        id => $client_code_id,
    });
    isa_ok($client_code,        "KA::ClientCode");
    is($client_code->is_valid,  1,              "Client Code is valid");
    
    # Now test with a good client code.
    my $good_client_code = KA::ClientCode->new;

    $context->client_code($good_client_code->id);
    $context->msg_id(124);

    $response = $ws_user->ws_clientCode($context);

    $client_code_id = $response->{clientCode};
    isnt($client_code_id,       undef,                  "Response: clientCode is defined");
    isnt($client_code_id,       undef,                  "There is a client code");
    is($client_code_id,         $good_client_code->id,  "Client code is unchanged");
}

sub test_ws_register {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        username    => 'joseph',
        email       => 'joe3@example.com',
    };
    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 456,
        content         => $content,
    });

    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");


    # Create a valid client code
    my $client_code = KA::ClientCode->new;
    $context->client_code($client_code->id);
    
    # Missing or too short a username should throw an error
    my @user_tests = ('', qw(a ab ));
    foreach my $username (@user_tests) {
        $content->{username} = $username;
        throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, no username [$username]";
        is($@->[0], 1001, "Code, too short a username");
        like($@->[1], qr/^Username must be at least 3 characters long/, "Message, username too short"); 
    }
    $content->{username} = 'alfred';
    
    # A missing email should throw an error
    delete $content->{email};
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'Throw, no email';
    is($@->[0], 1001, "Code, no email");
    like($@->[1], qr/^Email is missing/, "Message, no email");
   
    # Various invalid email addresses
    my @bad_emails = (
        'foo',
        'bar@',
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@example.com',
    );
    foreach my $email (@bad_emails) {
        $content->{email} = $email;
        throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, bad email [$email]";
        is($@->[0], 1001, "Code, bad email");
        like($@->[1], qr/^Email is invalid/, "Message, bad email");
    }
    $content->{email} = 'me@example.com';

    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');

    # Username should not already be in use
    $content->{username} = 'alfred';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing username";
    is($@->[0], 1001, "Code, existing username");
    like($@->[1], qr/^Username not available/, "Message, username already in use");

    # Email address should not already be in use
    $content->{username} = 'joseph';
    $content->{email} = 'bert@example.com';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing email";
    is($@->[0], 1001, "Code, existing email");
    like($@->[1], qr/^Email is not available/, "Message, email already in use");
    $content->{email} = 'joe@example.com';

    # A good client code, username and email should now work
    my $response;
    if (lives_ok { $response = $ws_user->ws_register($context) } 'good client code' ) {
        is_deeply($response, {
                username    => 'joseph',
                loginStage  => 'enterEmailCode',
            },
            "Response: data is deeply correct"
        );
    }
    else {
        diag(Dumper($@));
    }

    # A registration should have put a job on the job queue
    my $queue = KA::Queue->instance;
    my $job = $queue->peek_ready;
    isnt($job, undef, "Job is ready"); 
    $queue->delete($job->job->id);

    $fixtures->unload;
}


sub test_ws_forgotPassword {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');

    my $content = {
        usernameOrEmail    => 'joseph',
    };
    my $context = KA::WebSocket::Context->new({
        msg_id              => 457,
        client_code         => 'rubbish',
        content => $content,
    });
    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_forgotPassword($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $context->client_code(KA::ClientCode->new->id);

    # Blank username or email should return error
    $content->{usernameOrEmail} = "   ";
    throws_ok { $ws_user->ws_forgotPassword($context) } qr/^ARRAY/, "Throw, username/email is blank";
    is($@->[0], 1002, "Code, username/email is blank");
    like($@->[1], qr/^username_or_email is required/, "Message, username_or_email is required");

    # non-existing username or email should return success
    $content->{usernameOrEmail} = "username_unknown";
    my $response = $ws_user->ws_forgotPassword($context);

    # but no email job should be raised
    my $queue = KA::Queue->instance;
    my $job = $queue->peek_ready;

    is($job, undef, "No email job"); 
 
    # existing username should return success
    $content->{usernameOrEmail} = "alfred";
    unless ( lives_ok { $response = $ws_user->ws_forgotPassword($context) } 'good client code' ) {
        diag(Dumper($@));
    }
    # email job should be raised
    $job = $queue->peek_ready;
    isnt($job, undef, "Email Job should be raised");
    $queue->delete($job->job->id);

    # existing email should return success
    $content->{usernameOrEmail} = 'bert@example.com';
    unless ( lives_ok { $response = $ws_user->ws_forgotPassword($context) } 'good client code' ) {
        diag(Dumper($@));
    }
    # email job should be raised
    $job = $queue->peek_ready;
    isnt($job, undef, "Email Job should be raised");
    $queue->delete($job->job->id);

    # TODO Need to send out different email depending upon the registration
    # stage.
   
    


    # Job queue should now be empty
    $job = $queue->peek_ready;
    is($job, undef, "No more jobs");

    $fixtures->unload;

}

sub test_ws_loginWithPassword {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    # user (1) 'alfred' is in register_stage 'complete'
    # user (2) 'bernard', is in register_stage 'enterEmailCode'
    # user (3) 'charles' is is register_stage 'enterNewPassword'
    
    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');
    $fixtures->load('user_bernard');
    $fixtures->load('user_charles');

    my $content = {
        username    => 'alfred',
        password    => 'secret',
    };
    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 456,
        content         => $content,
    });

    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_loginWithPassword($context) } qr/^ARRAY/, 'test throw, invalid client code';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $context->client_code(KA::ClientCode->new->id);

    # No matching username should return an error
    $content->{username} = "someone_else";
    throws_ok { $ws_user->ws_loginWithPassword($context) } qr/^ARRAY/, "Throw, unknown username";
    is($@->[0], 1001, "Code, Unknown username");
    like($@->[1], qr/^Incorrect credentials 1/, "Message");
    $content->{username} = 'alfred';

    # No matching password should return an error
    $content->{password} = "hack_attack";
    throws_ok { $ws_user->ws_loginWithPassword($context) } qr/^ARRAY/, "Throw, incorrect password";
    is($@->[0], 1001, "Code, Incorrect Password");
    like($@->[1], qr/^Incorrect credentials 2/, "Message");
    $content->{password} = 'secret';

    # Correct username and password should log in
    my $response;
    unless ( lives_ok { $response = $ws_user->ws_loginWithPassword($context) } 'good login' ) {
        diag(Dumper($@));
    }
    is($context->client_data->{user}{id}, 1, "Correct user id");
    $fixtures->unload;
}

sub test_ws_enterNewPassword {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    # user (1) 'alfred' is in register_stage 'complete'
    # user (2) 'bernard', is in register_stage 'enterEmailCode'
    # user (3) 'charles' is is register_stage 'enterNewPassword'
    
    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');
    $fixtures->load('user_bernard');
    $fixtures->load('user_charles');

    my $content = {
        password    => 'Top5ecr3t',
    };
    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 456,
        content         => $content,
    });

    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, 'test throw, invalid client code';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $context->client_code(KA::ClientCode->new->id);

    # If user is not logged in, it should throw an error
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, 'test throw, user not logged in';

    # User who has completed registration should be allowed to change password.
    my $user = $db->resultset('User')->find({
        id      => 1,
    });
    $context->client_data->{user} = $user->as_hash;

    # Password should not be too short
    $content->{password} = 'T1ny';
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, "Throw, short password";
    is($@->[0], 1001, "Code, password too short");
    like($@->[1], qr/^Password must be at least 5 characters long/, "Message, password is too short");
    #
    # Password should contain upper case characters
    $content->{password} = 'onlylow3r';
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, "Throw, password has no upper case";
    is($@->[0], 1001, "Code, password has no upper case characters");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no upper case characters");

    # Password should contain lower case characters
    $content->{password} = '0NLYUPR';
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, "Throw, password has no lower case";
    is($@->[0], 1001, "Code, password has no lower case characters");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no lower case characters");

    # Password should contain numeric characters
    $content->{password} = 'noNumBers';
    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, "Throw, password has no numbers";
    is($@->[0], 1001, "Code, password has no numbers");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no numeric characters");

    $content->{password} = 'TopS3cr3t';

    my $response;
    if ( lives_ok { $response = $ws_user->ws_enterNewPassword($context) } 'good password change' ) {
        is_deeply($response, {
            loginStage  => 'complete',
        });
    }

    # If user is in 'enterNewPassword' stage then it should not throw an error
    $user = $db->resultset('User')->find({
        id      => 3,
    });
    $context->client_data->{user} = $user->as_hash;

    if ( lives_ok { $response = $ws_user->ws_enterNewPassword($context) } 'good password change' ) {
        is_deeply($response, {
            loginStage  => 'complete',
        });
    }

    # If user is in any other state, it should throw an error
    $user = $db->resultset('User')->find({
        id      => 2,
    });
    $context->client_data->{user} = $user->as_hash;

    throws_ok { $ws_user->ws_enterNewPassword($context) } qr/^ARRAY/, 'throws error for wrong registration state';
    is($@->[0], 1002, "Code");
    like($@->[1], qr/^Cannot change password yet/, "Message");

}


sub test_ws_loginWithEmailCode {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    # user (1) 'user_alfred' is in register_stage 'complete'
    # user (2) 'user_bernard', is in register_stage 'enterEmailCode'
    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');

    my $email_code = KA::EmailCode->new({ user_id => 1 });

    my $content = {
        emailCode          => $email_code->id,
    };
    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 456,
        content         => $content,
    });

    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_loginWithEmailCode($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $context->client_code(KA::ClientCode->new->id);

    # No email_code should return an error
    $content->{emailCode} = "";
    throws_ok { $ws_user->ws_loginWithEmailCode($context) } qr/^ARRAY/, "Throw, email code is blank";
    is($@->[0], 1001, "Code, no email code");
    like($@->[1], qr/^Invalid Email Code/, "Message");

    # No matching email_code should return an error
    $content->{emailCode} = "something_else";
    throws_ok { $ws_user->ws_loginWithEmailCode($context) } qr/^ARRAY/, "Throw, unknown email_code";
    is($@->[0], 1001, "Code Invalid Email Code");
    like($@->[1], qr/^Invalid Email Code/, "Message");

    # Email code should only apply to user in login_stage 'enterEmailCode'
    $content->{emailCode} = $email_code->id;
    throws_ok { $ws_user->ws_loginWithEmailCode($context) } qr/^ARRAY/, 'Throw, not registration stage enterEmailCode';
    is($@->[0], 1002, "Email Registration no longer valid.");
    like($@->[1], qr/^Email Registration no longer valid./, "Message");

    # Login should succeed if all conditions are met
    $fixtures->load('user_bernard');
    $email_code = KA::EmailCode->new({ user_id => 2 });
    $content->{emailCode} = $email_code->id;

    my $response;
    if ( lives_ok { $response = $ws_user->ws_loginWithEmailCode($context) } 'good login' ) {
        is_deeply($response, {
            username    => 'bernard',
            loginStage  => 'enterNewPassword',
        });
    }
    else {
        diag(Dumper($@));
    }

    is($context->client_data->{user}{id}, 2, "Correct user id");
    $fixtures->unload;
}

sub test_ws_logout {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $context = KA::WebSocket::Context->new({
        client_code     => 'invalid',
        msg_id          => 467,
        content         => undef,
    });

    my $ws_user = KA::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_logout($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $context->{client_code} = KA::ClientCode->new->id;

    my $db = KA::SDB->db;
    my $fixtures = UnitTestsFor::Fixtures::WebSocket::User->new( { schema => $db } );
    $fixtures->load('user_alfred');
    my $user = $db->resultset('User')->find({
        id => 1,
    });

    # If you are not logged in, it should return success
    undef $context->client_data->{user};

    my $response;
    unless ( lives_ok { $response = $ws_user->ws_logout($context) } 'good logout 1' ) {
        diag(Dumper($@));
    }

    # If you are logged in, it should return success.
    $context->client_data->{user} = $user->as_hash;

    unless ( lives_ok { $response = $ws_user->ws_logout($context) } 'good logout 2' ) {
        diag(Dumper($@));
    }

    is($context->client_data->{user}{id}, undef, "User is logged out");
    $fixtures->unload;
}
1;

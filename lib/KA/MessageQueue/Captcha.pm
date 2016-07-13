package KA::MessageQueue::Captcha;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;
use Time::HiRes qw(gettimeofday);

use KA::SDB;
use KA::Queue;
use KA::CaptchaFactory;
use KA::Config;

sub log {
    my ($self) = @_;
    my $server = "User";
    return Log::Log4perl->get_logger( __PACKAGE__ );
}

#--- Generate a new captcha
#
sub bg_generate {
    my ($self, $context) = @_;

    $self->log->debug("BG_Captcha generate");

    my $config = KA::Config->instance;

    my $captcha_factory = KA::CaptchaFactory->new({
        develop_mode    => $config->get('develop_mode') ? 1 : 0,
        fonts           => $config->get('captcha/fonts'),
        font_path       => $config->get('captcha/fontpath'),
    });
    $captcha_factory->construct;
    $self->log->debug("Captcha created [".$captcha_factory->guid."]");

    # Remove all captchas older than 1hr (except for one)
    #
    # select * from captcha where created < DATE_SUB(now(), INTERVAL 1 HOUR) order by id desc;
    #
    my $captchas = KA::SDB->instance->db->resultset('Captcha')->search({
        created => \"< DATE_SUB(now(), INTERVAL 1 HOUR)",
    },{
        order_by => { -desc => 'id' },
    });
    # Make sure there is at least one left irrespective of it's age
    my $captcha = $captchas->next;

    while ($captcha = $captchas->next) {
        $self->log->debug("Deleting captcha [".$captcha->id."]");

        my $prefix  = substr($captcha->guid, 0,2);
        my $file    = "/data/captcha/$prefix/".$captcha->guid.".png";
        $self->log->debug("Deleting file [$file]");
        unlink($file);
        $captcha->delete;
    }
}

1;

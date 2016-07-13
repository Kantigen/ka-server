package KA::DB::Result::Schedule;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'KA::DB::Result';
use DateTime;
use Scalar::Util qw(weaken);
use KA::Util qw(format_date);
use Digest::SHA;
use List::MoreUtils qw(uniq);
use Email::Stuff;
use Email::Valid;
use UUID::Tiny ':std';
use KA::Constants qw(INFLATION);
use Data::Dumper;
use KA::Queue;

extends 'KA::DB::Result';

#--- The 'schedule' table represents jobs on the Message Queues which are scheduled to
#   occur at some point in the future, e.g. A ship arriving, a building completing an upgrade,
#   a ship construction being completed.
#
#   The scheduler task keeps track of the MQ event in parallel, this means that if, for some
#   event, the MQ needs to be recreated then it can be created from this table.
#
#   It also means, if an event is rescheduled (for example if a build-queue is boosted) then
#   the original timed event can be removed from the MQ and a new event, with a different time
#   can replace it
#
#   At some point in the future, if the number of entries on the MQ exceed some limit, it might
#   be possible to only put entries on the MQ that are scheduled to occur (say) in the coming
#   hour, all others can be left on the 'schedule' table.
#   
__PACKAGE__->table('schedule');
__PACKAGE__->add_columns(
    queue       => {data_type => 'varchar',     size => 30, is_nullable => 0},
    job_id      => {data_type => 'int',         size => 11, is_nullable => 0},
    delivery    => {data_type => 'datetime',                is_nullable => 0},
    priority    => {data_type => 'int',         size => 11, is_nullable => 0,   default_value => 2000},
    route       => {data_type => 'varchar',     size => 64, is_nullable => 0},
    db_id       => {data_type => 'int',         size => 11, is_nullable => 0},
    payload     => {data_type => 'mediumblob',              is_nullable => 1,   serializer_class => 'JSON'},
);

after 'insert' => sub {
    my $self = shift;

    # an enhancement would to only put entries on beanstalk that are due within the hour
    # and also have an hourly cron job for entries that became due in the following hour
    $self->queue_for_delivery;
    
    return $self;
};

before 'delete' => sub {
    my $self = shift;
   
    my $queue = KA::Queue->instance;
    # Delete the job off the queue
    $queue->delete($self->job_id);
};

# Put this entry onto the beanstalk queue
#
sub queue_for_delivery {
    my ($self) = @_;

    my $now_epoch   = DateTime->now->epoch;
    my $delivery    = $self->delivery;
    my $del_epoch   = $delivery->epoch;
    my $delay       = $del_epoch - $now_epoch;
    $delay          = 0 if $delay < 0;
    my $now         = DateTime->now;

    my $queue       = KA::Queue->instance;
    my $priority    = $self->priority || 2000;
    my $job = $queue->publish({
        queue       => $self->queue,
        payload     => $self->payload,
        route       => $self->route,
        delay       => $delay,
        priority    => $priority,
    })->recv;
    $self->job_id($job->id);
    $self->update;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);


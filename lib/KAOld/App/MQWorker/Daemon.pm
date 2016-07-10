package KA::App::MQWorker::Daemon;

use Moose;
use MooseX::App::Command;
use Data::Dumper;
use namespace::autoclean;
use App::Daemon qw(daemonize);
use Log::Log4perl qw(:levels);
use Try::Tiny;

use KA::MessageQueue;

extends 'KA::App::MQWorker';

option 'nodaemonize' => (
    is              => 'rw',
    isa             => 'Bool',
    required        => 0,
    default         => 0,
    documentation   => 'Run in the foreground.',
);

option 'verbose' => (
    is              => 'rw',
    isa             => 'Bool',
    required        => 0,
    default         => 0,
    documentation   => 'Verbose messages.',
);

sub run {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger('KA::MessageQueue');

    print "Run the Message Queue daemon [".$self->nodaemonize."]\n";

    $App::Daemon::loglevel = $self->verbose ? $DEBUG : $WARN;
    $App::Daemon::logfile = '/home/keno/ka-server/log/MQWorkerDaemon.log';

    my $pid_file = '/home/keno/ka-server/log/MQWorkerDaemon.pid';
    my $start = time;

    # Kill any existing process
    if (-f $pid_file) {
        open(my $pid_fh, $pid_file);
        my $pid = <$pid_fh>;
        chomp $pid;
        close($pid_fh);

        if (grep /$pid/,`ps -p $pid`) {
            $self->out("Killing previous job, PID=$pid");
            kill 9, $pid;
            sleep 5;
        }
    }

    #--- Daemonize
    #
    if ($self->nodaemonize) {
        $self->out('Running in the foreground');
    }
    else {
        daemonize();
        $self->out('Running as a daemon');
    }

    my $config          = KA::Config->instance;
    my $queue           = KA::Queue->instance;
    my $message_queue   = KA::MessageQueue->new({
        name    => 'mq_worker',
    });

    #--- Hard code the queues to watch, they should come
    # TODO from the command line
    #
    $self->out('Started');
    $queue->watch('mq_worker');

    while (1) {
        my $job = $queue->consume;
        my $payload = $job->payload;

        try {
            $self->out("Process job ".Dumper($payload));
            $message_queue->queue($job);

            $job->delete;
        }
        catch {
            # Bury the job, it failed
            $log->error("Job failed: $_");
            $job->bury;
        };
    }
}

sub out {
    my ($self, $message) = @_;

    print STDERR "$message\n";
}

__PACKAGE__->meta->make_immutable;


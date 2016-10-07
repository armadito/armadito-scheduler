package Armadito::Scheduler::Daemon::Linux;

use strict;
use warnings;

use base 'Armadito::Scheduler::Daemon';
use POSIX ":sys_wait_h";
use Try::Tiny;

sub new {
	my ( $class, %params ) = @_;
	my $self = $class->SUPER::new(%params);

	return $self;
}

sub run {
	my ( $self, %params ) = @_;
	$self = $self->SUPER::run(%params);

	$self->waitUntilRoundZero();
	$self->{logger}->info("RoundZero !");

	$self->start();

	return $self;
}

sub execTask {
	my ( $self, $task ) = @_;
	$self->{logger}->info("Exec task $task->{name}");

	# Exec only one same task at the same time
	my %workers = %{ $self->{workers} };
	if ( defined( $workers{ $task->{name} } ) ) {
		return;
	}

	my $proc_id = fork();
	if ( $proc_id == 0 ) {
		$self->execTaskCmd($task);
		exit(0);
	}
	else {
		if ( defined($proc_id) ) {
			$self->addWorker( $task, $proc_id );
		}
		else {
			$self->{logger}->info("Error when trying to fork watchdog.");
		}
	}
}

sub execTaskCmd {
	my ( $self, $task ) = @_;
	try {
		system "sg " . $task->{user} . " -c '" . $task->{cmd} . "'";
	}
	catch {
		print STDERR "execTaskCmd Failure:\n";
		print STDERR $_;
		exit(1);
	};
}

sub waitForChild {
	my ( $self, $key ) = @_;

	my %workers    = %{ $self->{workers} };
	my $worker_pid = $workers{$key}->{pid};

	if ( $worker_pid > 0 ) {

		# No blocking wait
		my $res = waitpid( $worker_pid, WNOHANG );
		sleep(0.1);

		if ( $res == 0 ) {
			$workers{$key}->{time_to_live}--;
			if ( $workers{$key}->{time_to_live} <= 0 ) {
				$self->killWorker($worker_pid);
			}
		}
		else {
			delete ${ $self->{workers} }{$key};
		}
	}
}

sub killWorker {
	my ( $self, $pid ) = @_;

	$self->{logger}->info("Try to kill process $pid \n");

	eval { kill 9, $pid; };
	if ($@) {
		$self->{logger}->info("Cannot kill process $pid \n");
	}
}

sub addWorker {
	my ( $self, $task, $proc_id ) = @_;

	${ $self->{workers} }{ $task->{name} } = {
		proc_obj     => "",
		pid          => $proc_id,
		time_to_live => $task->{time_to_live},
		task         => $task
	};
}
1;

__END__

=head1 NAME

Armadito::Scheduler::Daemon::Linux - Daemon implementation for Linux.

=head1 DESCRIPTION

TODO

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the daemon.

=head2 new ( $self, %params )

Instanciate Daemon. Set daemon's default logger.

package Armadito::Scheduler::Daemon;

use strict;
use warnings;
use Time::HiRes qw(usleep gettimeofday tv_interval sleep);
use Armadito::Scheduler::Logger;
use Data::Dumper;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Scheduler::Logger->new(),
		config => $params{config},
		workers => []
	};

	$self->{id}             = 5;
	$self->{round_duration} = 10;

	bless $self, $class;
	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
}

sub nextRound {
	my ( $self, %params ) = @_;

ROUNDSTART:
	my $start = [gettimeofday];

	#$self->waitRandomly( max => int( $self->{round_duration} / 2 ) );
	$self->runTasks();

	my $elapsed = tv_interval( $start, [gettimeofday] );
	$self->waitUntilNextRound($elapsed);

	goto ROUNDSTART;
}

sub runTasks {
	my ( $self, %params ) = @_;
	my @tasks = @{ $self->{config}->{tasks} };

	foreach my $task (@tasks) {

		$task->{rounds_to_wait} = $self->_getRoundsToWait($task);
		$self->{logger}->info( $task->{name} . " rounds_to_wait=" . $task->{rounds_to_wait} );

		if ( $task->{rounds_to_wait} < 1 ) {
			$self->{logger}->info("Run task $task->{name}");

			#&createLinuxProcess($task);
			$task->{rounds_to_wait} = $task->{frequency} - 1;
		}
		else {
			$task->{rounds_to_wait}--;
		}
	}
}

sub _getRoundsToWait {
	my ( $self, $task ) = @_;

	my $round_to_be   = $task->getRoundToBe( $self->{id} );
	my $current_round = $task->getCurrentRound( $self->{round_duration} );

	my $rounds_to_wait = $round_to_be - $current_round;
	if ( $rounds_to_wait < 0 ) {
		$rounds_to_wait = $task->{frequency} + $rounds_to_wait;
	}

	return $rounds_to_wait;
}

sub waitUntilRoundZero {
	my ($self) = @_;

	my ( $now_sec, $now_micro ) = gettimeofday;
	do {
		sleep(0.01);
		( $now_sec, $now_micro ) = gettimeofday;

	} while ( $now_sec % $self->{round_duration} );
}

sub waitRandomly {
	my ( $self, %params ) = @_;

	my $waiting_duration = int( rand( $params{max} ) );
	sleep($waiting_duration);
}

sub waitUntilNextRound {
	my ( $self, $elapsed_time ) = @_;

	my $sleep_duration = $self->{round_duration} - $elapsed_time;

	$self->{logger}->info( "sleep_duration : " . $sleep_duration );
	sleep($sleep_duration);
}

1;

__END__

=head1 NAME

Armadito::Scheduler::Daemon - Daemon base class.

=head1 DESCRIPTION

TODO

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the daemon.

=head2 new ( $self, %params )

Instanciate Daemon. Set daemon's default logger.

=head2 waitUntilZeroSlot ()

Wait until the initial slot of an execution loop.
If loop_duration is equals to 60 (seconds), it means that slot "zero" is at 00 seconds of each minutes :
 - 14:00:00 14:01:00 ... 14:35:00 ...

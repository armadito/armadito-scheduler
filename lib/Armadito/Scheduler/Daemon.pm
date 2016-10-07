package Armadito::Scheduler::Daemon;

use strict;
use warnings;
use Time::HiRes qw(usleep gettimeofday tv_interval sleep);
use Armadito::Scheduler::Logger;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Scheduler::Logger->new(),
		config => $params{config},
		workers => []
	};

	$self->{round_duration} = 60;

	bless $self, $class;
	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
}

sub doRound {
	my ( $self, %params ) = @_;

	$self->{logger}->debug2("ROUND!\n");
}

sub waitUntilZeroSlot {
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

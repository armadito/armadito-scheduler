package Armadito::Scheduler::Daemon::Linux;

use strict;
use warnings;

use base 'Armadito::Scheduler::Daemon';

sub new {
	my ( $class, %params ) = @_;
	my $self = $class->SUPER::new(%params);

	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
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

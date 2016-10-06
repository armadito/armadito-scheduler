package Armadito::Scheduler::Daemon::Win32;

use strict;
use warnings;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Scheduler::Logger->new(),
		config => $params{config}
	};

	bless $self, $class;
	return $self;
}

sub run {
	my ( $self, %params ) = @_;

	return $self;
}
1;

__END__

=head1 NAME

Armadito::Scheduler::Daemon::Win32 - Daemon implementation for Windows.

=head1 DESCRIPTION

TODO

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the daemon.

=head2 new ( $self, %params )

Instanciate Daemon. Set daemon's default logger.

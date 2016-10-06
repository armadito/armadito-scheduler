package Armadito::Scheduler::Task;

use strict;
use warnings;

use Armadito::Scheduler::Logger;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		logger => $params{logger} || Armadito::Scheduler::Logger->new(),
		config => $params{config},
		agent  => $params{agent}
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

Armadito::Scheduler::Task - Armadito Scheduler Task base class.

=head1 DESCRIPTION

This is a base class for each scheduled Tasks

=head1 FUNCTIONS

=head2 run ( $self, %params )

Run the task.

=head2 new ( $self, %params )

Instanciate Task. Set task's default logger.

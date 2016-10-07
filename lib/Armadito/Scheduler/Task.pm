package Armadito::Scheduler::Task;

use strict;
use warnings;

use Armadito::Scheduler::Logger;

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		name               => $params{name},
		cmd                => $params{cmd},
		frequency          => $params{frequency},
		time_to_live       => $params{time_to_live},
		user               => $params{user},
		rounds_to_wait     => 0,
		exec_in_this_round => 0,
		logger             => undef,
		config             => undef
	};

	bless $self, $class;
	return $self;
}

sub setLogger {
	my ( $self, $logger ) = @_;
    $self->{logger} = $logger;
}

sub setConfig {
	my ( $self, $config ) = @_;
    $self->{config} = $config;
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

=head2 setLogger ( $self, $logger )

Set task's logger.

=head2 setConfig ( $self, $config )

Set task's config.

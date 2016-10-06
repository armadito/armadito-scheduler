package Armadito::Scheduler::Tools;

use strict;
use warnings;
use base 'Exporter';
use English qw(-no_match_vars);

our @EXPORT_OK = qw(
	getNoWhere
);

sub getNoWhere {
	return $OSNAME eq 'MSWin32' ? 'nul' : '/dev/null';
}

1;
__END__

=head1 NAME

Armadito::Scheduler::Tools - Various tools

=head1 DESCRIPTION

This module provides some basic functions for multiple usages.

=head1 FUNCTIONS

=head2 getNoWhere()

Get OS noWhere. For example: /dev/null on Linux.

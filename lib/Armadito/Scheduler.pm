package Armadito::Scheduler;

use 5.008000;
use strict;
use warnings;

require Exporter;

our $VERSION = '0.0.2_01';

sub new {
	my ( $class, %params ) = @_;

	my $self = {
		status  => 'unknown',
		confdir => $params{confdir},
		datadir => $params{datadir},
		libdir  => $params{libdir},
		vardir  => $params{vardir},
		sigterm => $params{sigterm},
		targets => [],
		tasks   => []
	};
	bless $self, $class;

	return $self;
}

1;
__END__

=head1 NAME

Armadito::Scheduler - Task scheduler solution for armadito-agent

=head1 DESCRIPTION

This is an experimental task scheduling solution. 
It has been conceived in order to have an equitable repartition of tasks in time.

=head1 SEE ALSO

=over 4

=item * L<https://github.com/armadito>

Armadito organization on github.

=back

=head1 AUTHOR

vhamon, E<lt>vhamon@teclib.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Teclib'

=head1 LICENSE

This software is licensed under the terms of GPLv3, see COPYING file for
details.

=cut

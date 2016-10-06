package Armadito::Scheduler::Config;

use strict;
use warnings;

use English qw(-no_match_vars);
use File::Spec;
use Getopt::Long;
use UNIVERSAL::require;

my $default = {
	'conf-reload-interval' => 0,
	'debug'                => undef,
	'logger'               => 'Stderr',
	'logfile'              => undef,
	'logfacility'          => 'LOG_USER',
	'logfile-maxsize'      => undef,
	'stdout'               => undef
};

my $deprecated = {};

sub new {
	my ( $class, %params ) = @_;

	my $self = {};
	bless $self, $class;

	$self->_loadDefaults();
	$self->_loadFromBackend( $params{options}->{'conf-file'}, $params{options}->{'config'}, $params{confdir} );

	$self->_overrideWithArgs(%params);
	$self->_checkContent();

	return $self;
}

sub _overrideWithArgs {
	my ( $self, %params ) = @_;

	foreach my $key ( keys %{$self} ) {
		if ( defined( $params{options}->{$key} ) && $params{options}->{$key} ne "" ) {
			$self->{$key} = $params{options}->{$key};
		}
	}
}

sub _loadDefaults {
	my ($self) = @_;

	foreach my $key ( keys %$default ) {
		$self->{$key} = $default->{$key};
	}
}

sub _loadFromBackend {
	my ( $self, $confFile, $config, $confdir ) = @_;

	my $backend
		= $confFile            ? 'file'
		: $config              ? $config
		: $OSNAME eq 'MSWin32' ? 'registry'
		:                        'file';

SWITCH: {
		if ( $backend eq 'registry' ) {
			die "Unavailable configuration backend\n"
				unless $OSNAME eq 'MSWin32';
			$self->_loadFromRegistry();
			last SWITCH;
		}

		if ( $backend eq 'file' ) {
			$self->_loadFromFile(
				{
					file      => $confFile,
					directory => $confdir,
				}
			);
			last SWITCH;
		}

		if ( $backend eq 'none' ) {
			last SWITCH;
		}

		die "Unknown configuration backend '$backend'\n";
	}
}

sub _loadFromRegistry {
	my ($self) = @_;

	my $Registry;
	Win32::TieRegistry->require();
	Win32::TieRegistry->import(
		Delimiter   => '/',
		ArrayValues => 0,
		TiedRef     => \$Registry
	);

	my $machKey = $Registry->Open(
		'LMachine',
		{
			Access => Win32::TieRegistry::KEY_READ()
		}
	) or die "Can't open HKEY_LOCAL_MACHINE key: $EXTENDED_OS_ERROR";

	my $settings = $machKey->{"SOFTWARE/Armadito-Scheduler"};

	foreach my $rawKey ( keys %$settings ) {
		next unless $rawKey =~ /^\/(\S+)/;
		my $key = lc($1);
		my $val = $settings->{$rawKey};

		# Remove the quotes
		$val =~ s/\s+$//;
		$val =~ s/^'(.*)'$/$1/;
		$val =~ s/^"(.*)"$/$1/;

		if ( exists $default->{$key} ) {
			$self->{$key} = $val;
		}
		else {
			warn "unknown configuration directive $key";
		}
	}
}

sub _loadFromFile {
	my ( $self, $params ) = @_;
	my $file = $params->{file} ? $params->{file} : $params->{directory} . '/scheduler.cfg';

	if ($file) {
		die "non-existing file $file" unless -f $file;
		die "non-readable file $file" unless -r $file;
	}
	else {
		die "no configuration file";
	}

	my $handle;
	die "Config: Failed to open $file: $ERRNO" if ( !open $handle, '<', $file );

	while ( my $line = <$handle> ) {
		$line =~ s/#.+//;
		if ( $line =~ /([\w-]+)\s*=\s*(.+)/ ) {
			my $key = $1;
			my $val = $2;

			# Remove the quotes
			$val =~ s/\s+$//;
			$val =~ s/^'(.*)'$/$1/;
			$val =~ s/^"(.*)"$/$1/;

			if ( exists $default->{$key} ) {
				$self->{$key} = $val;
			}
			else {
				warn "unknown configuration directive $key";
			}
		}
	}
	close $handle;
}

sub _checkContent {
	my ($self) = @_;

	# check for deprecated options
	foreach my $old ( keys %$deprecated ) {
		next unless defined $self->{$old};

		next if $old =~ /^no-/ && !$self->{$old};

		my $handler = $deprecated->{$old};

		# notify user of deprecation
		warn "the '$old' option is deprecated, $handler->{message}\n";

		# transfer the value to the new option, if possible
		if ( $handler->{new} ) {
			if ( ref $handler->{new} eq 'HASH' ) {

				# old boolean option replaced by new non-boolean options
				foreach my $key ( keys %{ $handler->{new} } ) {
					my $value = $handler->{new}->{$key};
					if ( $value =~ /^\+(\S+)/ ) {

						# multiple values: add it to exiting one
						$self->{$key} = $self->{$key} ? $self->{$key} . ',' . $1 : $1;
					}
					else {
						# unique value: replace exiting value
						$self->{$key} = $value;
					}
				}
			}
			elsif ( ref $handler->{new} eq 'ARRAY' ) {

				# old boolean option replaced by new boolean options
				foreach my $new ( @{ $handler->{new} } ) {
					$self->{$new} = $self->{$old};
				}
			}
			else {
				# old non-boolean option replaced by new option
				$self->{ $handler->{new} } = $self->{$old};
			}
		}

		# avoid cluttering configuration
		delete $self->{$old};
	}

	# a logfile options implies a file logger backend
	if ( $self->{logfile} ) {
		$self->{logger} .= ',File';
	}

	# logger backend without a logfile isn't enoguh
	if ( $self->{'logger'} =~ /file/i && !$self->{'logfile'} ) {
		die "usage of 'file' logger backend makes 'logfile' option mandatory\n";
	}

	# multi-values options, the default separator is a ','
	foreach my $option (
		qw/
		logger
		/
		)
	{

		# Check if defined AND SCALAR
		# to avoid split a ARRAY ref or HASH ref...
		if ( $self->{$option} && ref( $self->{$option} ) eq '' ) {
			$self->{$option} = [ split( /,/, $self->{$option} ) ];
		}
		else {
			$self->{$option} = [];
		}
	}

	$self->{'logfile'} = File::Spec->rel2abs( $self->{'logfile'} )
		if $self->{'logfile'};
}

1;
__END__

=head1 NAME

Armadito::Scheduler::Config - Armadito Scheduler configuration

=head1 DESCRIPTION

This is the object used by the scheduler to store its configuration.

=head1 METHODS

=head2 new(%params)

The constructor. The following parameters are allowed, as keys of the %params
hash:

=over

=item I<confdir>

the configuration directory.

=item I<options>

additional options override.

=back

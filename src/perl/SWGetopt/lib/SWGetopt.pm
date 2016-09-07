package SWGetopt;

use strict;
use warnings;
use base 'Exporter';

our $VERSION = '0.01';

=head1 NAME

SWGetopt - A module for creating a command line interface

=head1 SYNOPSIS

This module allows a user to create a command line interface for an 
application.

=head1 DESCRIPTION

The SWGetopt module is maybe a bit too ambituous, the general idea 
behind this, is to provide a tool to create a command line interface
for an application, and at the same time make it self documenting.
It is based off of GNU C getopt/getopt_long ideas.

Goals:
	Simple clean interface builder for commandline option parsing.
	Documenting the interface is built in.
	This documentation includes: --help as well as manual docs.

=head1 OPTIONS

=head1 EXAMPLES

=head1 SEE ALSO

=head1 AUTOR

Kent Mein <mein@umn.edu>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2016 Kent Mein

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

my ($XXSUMMARY, $XXARGS);

our @EXPORT = qw(
	GetOptions
	usage
	set_args
	set_summary
	print_args
	print_summary
	print_options
);

sub GetOptions {
	my ($Options, @values) = @_;
	my ($regex, $simple, $command, $var, $tmp);

	foreach my $i (@values) {
		$simple = 0;
print "$i\n";
		if ($i =~ /(.*)=i/) {
			$var = $1;
			$regex = "(.*)=%d";
		
		} elsif ($i =~ /(.*)=s/) {
			$var = $1;
			$regex = "((\"[^\"\]]*";

		} elsif ($i =~ /(.*)=(.*)/) {
			print "Error in format $i should be VAR=i or VAR=s\n";
			return 0;
		} else {
			$regex = $i;
			$simple = 1;
		}

		# XXX Need to fix this...
		$command = $argv;

		if ($command =~ /^(.*)\s+$regex\s+(.*)/) {
			$tmp = $2; # Note this is in $regex
		} elsif ($command =~ /^$regex\s+(.*)/) {
			$tmp = $1; # again in $regex
		} elsif ($command =~ /(.*)\s+$regex/) {
			$tmp = $2; # again in $regex
		} elsif ($command =~ $regex) {
			$tmp = $1;
		}

		if ($simple) {
			$Options->{$regex} = 1;
		} else {
			$Options->{$var} = $tmp;
		}

		# XXX need to remove from env here...
	}

	return 1;
}

sub print_args {
	if ($XXARGS) {
		print $XXARGS;
		return 1;
	}

	return 0;
}

sub set_args {
}

sub print_summary {
	if ($XXSUMMARY) {
		print $XXSUMMARY;
		return 1;
	}

	return 0;
}

sub set_summary {
}

sub print_options {
}

sub usage {
	print "Usage: $0 " . print_args() . "\n";
	print print_summary() . "\n";
	print print_options() . "\n";

	return 1;
}

1;

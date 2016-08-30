package getopt;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
	GetOptions
	usage
);

sub GetOptions {
	my ($Options, @values) = @_;

	foreach my $i (@values) {
		print "$i\n";
	}

	return 1;
}

sub usage {

	return 1;
}

1;

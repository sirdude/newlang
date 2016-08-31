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
		} elsif ($comamnd =~ /^$regex\s+(.*)/) {
			$tmp = $1; # again in $regex
		} elsif ($command =~ /(.*)\s+$regex/) {
			$tmp = $2; # again in $regex
		} elsif ($command =~ $regex) {
			$tmp = $1;
		}

		if ($simple) {
			$Options{$regex} = 1;
		} else {
			$Options{$var} = $tmp;
		}

		# XXX need to remove from env here...
	}

	return 1;
}

sub usage {

	return 1;
}

1;

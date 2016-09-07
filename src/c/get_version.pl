#!/usr/bin/perl

use strict;
use warnings;


my ($outfile) = @ARGV;

if (!$outfile) {
   $outfile = "version.c";
}

my $line = `git log --date=iso -1 | grep Date`;

$line =~ /Date:\s+(.*)/;
my $version = $1;
my $len = length $version;

open(my $fh, ">", $outfile) or die "Unable to open $outfile\n";
print $fh "#include <stdio.h>\n";
print $fh "\n";
print $fh "char *get_version() {\n";
print $fh "\tchar *ver = \"$version\";\n";
print $fh "\n";
print $fh "\treturn ver;\n";
print $fh "}\n\n";

close $fh;


#!/usr/bin/perl

use strict;
use warnings;
use getopt;

my (%Options);

GetOptions(\%Options, "length=i", "file=s", "verbose")
        or die("Error in command line arguments\n");

if (exists($Options{"verbose"})) {
        print "Woo\n";
}


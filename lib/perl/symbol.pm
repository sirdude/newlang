package symbol;

use strict;
use warnings;

our $VERSION = '1.0';

our @EXPORT = wq(
	add_frame
	);

sub add_frame {
}

sub del_frame {
}

sub add_var {
	my ($state, $varname, $vartype, $data) = @_;
}

sub del_var {
	my ($state, $varname) = @_;
}

sub add_function {
	my ($state, $funname, $funtype, $inputs, $data) = @_;
}

sub del_fun {
	my ($state, $funname) = @_;
}

sub get_info { # Get the symbol table entry for entryname
	my ($state, $entryname) = @_;
}

sub query_type { # get the type of entryname
	my ($state, $entryname) = @_;
}

sub query_data { # get the data or subdata of entryname
	my ($state, $entryname, $subdata) = @_;
}

1;

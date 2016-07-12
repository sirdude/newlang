package statemachine;
my numsates = 0;

our EXPORT = qw(
	add_state
	add_link
	);

sub add_state {
	$numstates = $numstates + 1;
}

sub del_state {
	$numstates = $numstates - 1;
}

sub add_link {
}

sub del_link {
}

sub get_links {
	my ($state) = @_;
}



1;

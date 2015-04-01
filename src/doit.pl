#!/usr/bin/perl
# This is kind of dumb, but it allows me to keep the source dir clean.
# I'm using bnfc to generate a template for the language based on our
# Grammar file.
# bnfc generates a makefile, so lets add some modifications to it so we
# can clean up all the auto-generated crap.
# At the same time lets automate things so that we can rebuild our files.
# It makes it a pain to make changes but makes sure we don't lose any
# work.  I'll probably expand it to add a library of functions into the
# build system to make things simpler later.

use strict;
use warnings;

# Clean things up, make distclean do extra stuff
sub fix_makefile {
	my ($dir) = @_;
	my $binary;

	if ($dir eq "./lpc") {
		$binary = "LPC";
	} else {
		$binary = "SWEET";
	}
	system("perl -pi -e 's/distclean: clean\n/" .
	        "extraclean:\n\trm -rf Interpreter* $binary " .
		"*.bak testlpc\n\ndistclean: clean extraclean\n/g' " .
		"$dir/Makefile");
	system("perl -pi -e 's/.PHONY: clean distclean\n/" .
		".PHONY: clean distclean extraclean\n/g' $dir/Makefile");

	system("perl -pi -e 's/Wall/Wall -I./g' $dir/Makefile");

	if ($dir eq "./lpc") {
		system("perl -pi -e 's/all:/all: $binary/g'" .
			" $dir/Makefile");
        } else {
		system("perl -pi -e 's/all:/all: $binary/g'" .
			" $dir/Makefile");
	}

	open(my $fh, ">>", "$dir/Makefile") or 
		die "Unable to open $dir/Makefile\n";
	print $fh "Interpreter.o: Interpreter.h\n\t\${CC} \${CCFLAGS} -c " .
		"Interpreter.c\n";
	print $fh "\nmain.o:\n\t\${CC} \${CCFLAGS} -c " .
		"../main.c\n";

	print $fh "\n$binary: \${OBJS} Interpreter.o main.o\n";
	print $fh "\t\@echo \"Linking $binary...\"\n";
	print $fh "\t\${CC} \${CCFLAGS} \${OBJS} main.o -o$binary\n";
	close($fh);
}

# Copy over our templates to useful files, and then fix them up a bit.
sub create_newfiles {
	my ($dir) = @_;

	# Copy our defaults to new programs
	system("cp $dir/Skeleton.c $dir/Interpreter.c");
	system("cp $dir/Skeleton.h $dir/Interpreter.h");

	system("perl -pi -e 's/Skeleton.h/Interpreter.h/g' $dir/Interpreter.c");

	# Need to modify Interpreter.c

        # Hack to get rid of warnings adding extra headers stdlib.h and stdio.h
        system("perl -pi -e 's/#include \"Interpreter.h\"\n/" .
                "#include \"Interpreter.h\"\n#include <stdlib.h>\n" .
                "#include <stdio.h>\n/g' $dir/Interpreter.c");
}

# Things still todo for printer XXX
#   for c== '{' comment out this line:
#       /*     bufAppendC('\n'); */
#       mv      indent(); down after bufAppendC(c);
#  before c == '('  don't add space if right before identifier
# 
# before 'else' don't have a '\n' 

# Mods to Pretty Printer:
sub fix_printer {
	my ($dir) = @_;
	system("perl -pi -e 's/#define INDENT_WIDTH 2/" .
		"#define INDENT_WIDTH 3/g' $dir/Printer.c");
}

# Create our stuff with bnfc
system("bnfc -m -c -o lpc LPC.cf");
system("bnfc -m -c -o sweet SWEET_formal.cf");

foreach my $i ("./lpc", "./sweet") {
	fix_makefile($i);
	fix_printer($i);
	create_newfiles($i);
}

system("cd lpc; make");
system("cd sweet; make");

# Test our code
# system(".lpc/testLPC ../examp/ugly.c");
system("./lpc/LPC -p ../examp/ugly.c");

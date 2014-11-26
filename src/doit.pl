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

sub fix_makefile {

	# Clean things up, make distclean do extra stuff
	system("perl -pi -e 's/LPC.pdf TestLPC/LPC.pdf TestLPC lpc/g' " .
		"Makefile");
	system("perl -pi -e 's/distclean: clean\n/" .
	        "extraclean:\n\trm -rf Interpreter* lpc " .
		"*.bak testlpc\n\ndistclean: clean extraclean\n/g' Makefile");
	system("perl -pi -e 's/.PHONY: clean distclean\n/" .
		".PHONY: clean distclean extraclean\n/g' Makefile");
	system("perl -pi -e 's/all: TestLPC LPC.pdf/all: TestLPC LPC.pdf " .
		"lpc/g' Makefile");

	open(my $fh, ">>", "Makefile") or die "Unable to open Makefile\n";
	print $fh "Interpreter.o: Interpreter.h\n\t\${CC} \${CCFLAGS} -c " .
		"Interpreter.c\n";
	print $fh "\nlpc.o:\n\t\${CC} \${CCFLAGS} -c " .
		"lpc.c\n";
	print $fh "\nLPCLIBS=Absyn.o Lexer.o Parser.o Interpreter.o " .
		"Printer.o lpc.o\n";
	print $fh "\nlpc: \${LPCLIBS}\n";
	print $fh "\t\@echo \"Linking lpc...\"\n";
	print $fh "\t\${CC} \${CCFLAGS} \${LPCLIBS} -olpc\n";
	close($fh);
}

sub create_newfiles {
	# Copy our defaults to new programs
	system("cp Skeleton.c Interpreter.c");
	system("cp Skeleton.h Interpreter.h");

	system("perl -pi -e 's/Skeleton.h/Interpreter.h/g' Interpreter.c");

	# Need to modify Interpreter.c

        # Hack to get rid of warnings adding extra headers stdlib.h and stdio.h
        system("perl -pi -e 's/#include \"Interpreter.h\"\n/" .
                "#include \"Interpreter.h\"\n#include <stdlib.h>\n" .
                "#include <stdio.h>\n/g' Interpreter.c");
}

#   #define SPACE 3
#   renderC and friends change to this:
#           _n_ = _n_ + SPACE;
#   for { comment out this line:
#       /*     bufAppendC('\n'); */
#   for }
#       need to add an extra backup();
sub fix_printer {
	# Mods to Pretty Printer:
	system("perl -pi -e 's/int _n_;/#define SPACE 3\n\nint _n_;/g' " .
		"Printer.c");

	# This if broken XXX
	system("perl -pi -e 's/ \+ 2/ \+ SPACE/g' Printer.c");

	system("perl -pi -e 's/- 2;/- SPACE;\n     backup();/g' Printer.c");
	# Need to do this also... XXX
# 	system("perl -pi -e 's/\'{\')\n  {\n    bufAppendC(\'\n\');" .
#		/\'{\')\n  {\n/g' Printer.c");
}

# Create our stuff with bnfc
system("bnfc -m -c LPC.cf");
fix_makefile();
fix_printer();
create_newfiles();

system("make");

# Test our code
system("./TestLPC ../examp/ugly.c");
system("./lpc ../examp/ugly.c");

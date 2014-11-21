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

# Create our stuff with bnfc
system("bnfc -m -c LPC.cf");
system("make");
system("./testLPC jjj.c");

# Copy our defaults to new programs
system("cp Skeleton.c Interpreter.c");
system("cp Skeleton.h Interpreter.h");
system("cp Test.c lpc.c");

system("perl -pi -e 's/Skeleton.h/Interpreter.h/g' Interpreter.c");
# Need to modify Interpreter.c
        # Hack to get rid of warnings adding extra headers stdlib.h and stdio.h
        system("perl -pi -e 's/#include \"Interpreter.h\"\n/" .
                "#include \"Interpreter.h\"\n#include <stdlib.h>\n" .
                "#include <stdio.h>\n/g' Interpreter.c");


# Need to modify lpc.c

# Compile our interpreter
system("gcc -Wall -g -c Interpreter.c");
system("gcc -Wall -g -c lpc.c");
system("gcc -Wall -g -otestlpc Absyn.o Lexer.o Parser.o " .
        "Interpreter.o Printer.o lpc.o");

# Test our code
system("testlpc jjj.c");

# Clean things up, make distclean do extra stuff
system("perl -pi -e 's/distclean: clean\n/" .
        "extraclean:\n\trm -rf Interpreter* lpc.c lpc.h lpc *.bak\n\n" .
        "distclean: clean extraclean\n/g' Makefile");
system("perl -pi -e 's/.PHONY: clean distclean\n/" .
        ".PHONY: clean distclean extraclean\n/g' Makefile");


# Mods to printing
#   #define SPACE 3
#   renderC and friends change to this:
#           _n_ = _n_ + SPACE;
#   for { comment out this line:
#       /*     bufAppendC('\n'); */
#   for }
#       need to add an extra backup();


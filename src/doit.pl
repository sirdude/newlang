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
use File::Copy;

sub usage {
	print "USAGE: $0 -help [clean|build] [[conflict|test] lang]\n";
	print "\tbuild create our files and compile our languages.\n";
	print "\tclean clean things up.\n";
	print "\tconflict look for clonflicts in our grammar.\n";
	print "\t-help display this usage information.\n";
}

sub removelines {
	my ($start, $end, $file) = @_;
	my $in = "$file.tmp";
	my ($fhi, $fho, $c);

	$c = 0;
	copy($file, $in);
	open($fhi, "<", $in) or die "Unable to read $in\n";
	open($fho, ">", $file) or die "Unable to write to $file\n";
	while(my $line = <$fhi>) {
		$c = $c + 1;

		if (($c >= $start) && ($c <= $end)) {
			# Skip it
		} else {
			print $fho $line;
		}
	}
	close($fhi);
	close($fho);
	unlink($in);
}

sub insert_code {
	my ($code, $place, $file) = @_;
	my $in = "$file.tmp";
	my ($fhi, $fho, $c);

	$c = 0;
	copy($file, $in);
	open($fhi, "<", $in) or die "Unable to read $in\n";
	open($fho, ">", $file) or die "Unable to write to $file\n";
	while(my $line = <$fhi>) {
		$c = $c + 1;

		if ($c == $place) {
			print $fho $code;
		}
		print $fho $line;
	}
	close($fhi);
	close($fho);
	unlink($in);
}

# Clean things up, make distclean do extra stuff
sub fix_makefile {
	my ($dir) = @_;
	my $binary;

	if ($dir eq "./lpc") {
		$binary = "lpc";
	} elsif ($dir eq "./sweetf") {
		$binary = "sweetf";
	} else {
		$binary = "sweet";
	}
	system("perl -pi -e 's/distclean: clean\n/" .
	        "extraclean:\n\trm -rf Interpreter* $binary " .
		"*.bak testlpc\n\ndistclean: clean extraclean\n/g' " .
		"$dir/Makefile");
	system("perl -pi -e 's/.PHONY: clean distclean\n/" .
		".PHONY: clean distclean extraclean version.c\n/g' " .
		"$dir/Makefile");

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
	print $fh "Interpreter.o: Interpreter.h Interpreter.c\n" .
		"\t\${CC} \${CCFLAGS} -c Interpreter.c\n";
	print $fh "\nmain.o: ../main.c\n\t\${CC} \${CCFLAGS} -c " .
		"../main.c\n";

	print $fh "\n$binary: \${OBJS} Interpreter.o main.o version.o\n";
	print $fh "\t\@echo \"Linking $binary...\"\n";
	print $fh "\t\${CC} \${CCFLAGS} \${OBJS} main.o version.o " .
		"-o$binary -lconfig\n";

	print $fh "\nversion.c:\n";
	print $fh "\t\../get_version.pl ../version.c\n";

	print $fh "\nversion.o: version.c\n";
	print $fh "\t\${CC} \${CCFLAGS} -c ../version.c\n";
	print $fh "\ninstall: $binary\n";
	print $fh "\tmkdir -p ../../bin\n";
	print $fh "\tcp $binary ../../bin/$binary\n";

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
        my ($code, $file);
	$file = "$dir/Printer.c";
	system("perl -pi -e 's/#define INDENT_WIDTH 2/" .
		"#define INDENT_WIDTH 3/g' $file");

	# Add a function to backup a line.
	$code = "void backupline(void)\n" .
		"{\n" .
		"  if (buf_[cur_ - 1] == '\\n')\n" .
		"  {\n" .
		"    buf_[cur_ - 1] = 0;\n" .
		"    cur_--;\n" .
		"  }\n" .
		"}\n";

	insert_code($code, 83, $file);

	# Remove renderS("else");
	removelines(781, 781, $file);

	# Fix if else so it doesn't skip a line
	$code = "    int t;\n" .
		"    for(t=0; t<INDENT_WIDTH; " .
			"t++) {\n" .
		"      backup();\n" .
		"    }\n" .
		"    backupline();\n" .
		"    renderS(\" else\");\n";
	insert_code($code, 781, $file);

	# Delete the newline before \{
	removelines(20, 21, $file);
}

sub create {
	my ($type) = @_;
	my @dirs;

	if (!$type || $type eq "") {
		system("bnfc -m -c -o lpc LPC.cf");
		system("bnfc -m -c -o sweet SWEET_actual.cf");
		system("bnfc -m -c -o sweetf SWEET_formal.cf");
		@dirs = ("./lpc", "./sweet", "./sweetf");

	} elsif ($type eq "lpc") {
		system("bnfc -m -c -o lpc LPC.cf");
		@dirs = "./lpc";
	} elsif ($type eq "sweetf") {
		system("bnfc -m -c -o sweetf SWEET_formal.cf");
		@dirs = "./sweetf";
	} else {
		system("bnfc -m -c -o sweet SWEET_actual.cf");
		@dirs = "./sweet";
	}

	foreach my $i (@dirs) {
		fix_makefile($i);
#		fix_printer($i);
		create_newfiles($i);
		system("cd $i; make; make install");
	}
}

# Test our code
sub test {
	my ($test) = @_;
	my ($bin, $examp);

	if (!$test || $test eq "") {
		test("lpc");
		test("sweetf");
		test("sweet");
		return;
	} elsif ($test eq "lpc") {
		$bin = "../bin/lpc";
		$examp = "../examp/ugly.c";
	} elsif ($test eq "sweetf") {
		$bin = "../bin/sweetf";
		$examp = "../examp/ugly.sw";
	} else {
		$bin = "../bin/sweet";
		$examp = "../examp/ugly.sw";
	}

	if (-f $bin) {
		print "Calling: $bin -p $examp\n";
		system("$bin -p $examp");
	} else {
		print "You need to first run: $0 build\n";
	}
}

sub clean {
	my ($type) = @_;

	if (!$type || $type eq "") {
		system("rm -rf lpc lpcinfo sweetinfo sweetfinfo sweet sweetf");
		system("rm -rf version.c ../bin");
	} elsif ($type eq "lpc") {
		system("rm -rf lpc lpcinfo version.c");
	} elsif ($type eq "sweetf") {
		system("rm -rf sweetf sweetfinfo version.c");
	} else {
		system("rm -rf sweet sweetinfo version.c");
	}
}

sub conflict {
	my ($type) = @_;
	my ($source, $dir, $info);

	if (!$type || $type eq "") {
		conflict("lpc");
		conflict("sweetf");
		conflict("sweet");
		return;
	} elsif ($type eq "lpc") {
		$source = "LPC.cf";
		$dir = "lpcinfo";
		$info = "ParLPC";
	} elsif ($type eq "sweetf") {
		$source = "SWEET_actual.cf";
		$dir = "sweetinfo";
		$info = "ParSWEET_actual";
	} else {
		$source = "SWEET_formal.cf";
		$dir = "sweetfinfo";
		$info = "ParSWEET_formal";
	}
	system("bnfc -m $source -o $dir");
	print "\n\nYou should look at $dir/$info.info " .
		"for the following issues\n";
	system("happy -i $dir/$info.y");
	system("grep \"(reduce\" $dir/$info.info");
#	system("happy -da $dir/$info.y");
}

my @values = @ARGV;
if (exists($values[0])) {

if (!exists($values[1])) {
	$values[1] = "";
}

	if ($values[0] eq "conflict") {
		conflict($values[1]);
	} elsif (($values[0] eq "build") || ($values[0] eq "create")) {
		create($values[1]);
	} elsif ($values[0] eq "clean") {
		clean($values[1]);
	} elsif ($values[0] eq "test") {
		test($values[1]);
	} else {
		usage();
	}
} else {
	usage();
}

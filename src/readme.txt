There are currently three implementations that are being developed in
parallel:  perl, c, sweet

The idea behind this is to compare contrast things and learn what works
well in developing sweet.  This is still pretty early stages so each
sub directory has different things in it currently.  Eventually this will
standardize and be fully fleshed out.

Our compiler needs the following libraries/modules:

Getopt		(commandline interface)
A Statemachine
A Symbol table
AST handler (reader/writer)


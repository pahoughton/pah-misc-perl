our %Doc;
$Doc{ File }	=   "test.pl";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "Script to regression test Options.pm module.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "05/30/01 08:54";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";

$Doc{ VERSION } = "+VERSION+";

#
# Revision History: (See end of file for Revision Log)
#

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use App::Options;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

our @Options =
  (
   [ "help+",		undef,
			"",	    "opt",
			"Output usage information.",
			"The amount of information increases each"
			." time it appears on the command line."
			." The first instance just outputs the available"
			." command line arguments. Successive instances"
			." (i.e. -help -help -help) provide additional"
			." information up to 4 which output the entire"
			." program documentation." ],

   [ "man",		undef,
			"",	    "opt",
			"Output the entire program documentation.",
			"This is just a short cut for using -help 4 times" ],

   [ "nopager",		undef,
			"",	    "opt",
			"Don NOT use pager for help output",
			"When ever the help (or man) text has more lines"
			." that your terminal window, the default pager"
			." is used to keep the text from scrolling off"
			." the screen. To keep the pager from being used,"
			." put this option on the command line." ],

   [ "show-opts",	undef,
			"",	    "opt",
			"Show option and env values then exit.",
			"Output the command line options and their respective"
			." current values. Also output any relevant"
			." environment variables and their respective"
			." values." ],

   [ "debug+",		undef,
			"",	    "opt",
			"Output debug information.",
			"Increments the amount of debug information"
			." each time it is found in the arguments. So,"
			." no --debug sets debug level to 0 (none),"
			." one -debug sets it to 1 and -debug -debug"
			." sets the debug level to 2. The higher the"
			." level, the more debug information is"
			." output." ],
   [ "version",		undef,
			"",	    "opt",
			"Show version and exit.",
			"Output the program's version information"
			." then exit" ]
   );

$App::Options::debug = 1;
my $opts  = new App::Options( OPTIONS => \@Options );



#
# Revision Log:
#
# %PL%
#

# Set XEmacs mode
#
# Local Variables:
# mode:perl
# End:
  

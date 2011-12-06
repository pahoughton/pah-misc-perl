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
$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
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
  ( @App::Options::StdOpts,
    [ "test-opt=s",	undef,
			"STRING",	    "opt",
			"test option",
			"just for testing" ]
   );

$App::Options::debug = 1;
my $opts  = new App::Options( OPTIONS => \@Options );

# $opts->{ 'option' }->{ 'arg-file' } = "test.args";
$opts->gen_arg_file();

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
  

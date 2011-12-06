our %Doc;
$Doc{ File }	=   "test.pl";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "script to regression test Debug.pm module";

$Doc{ Description } = "


";
$Doc{ Notes } = "

";
$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
$Doc{ Created } = "05/30/01 06:36";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";

#
# Revision History: (See end of file for Revision Log)
#

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use App::Debug;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my $testNum = 1;;
my $testPasses = 1;
my $testFailures = 0;
my $cfgError;
my $debug = 0;

sub TestIt {
  my ($result,$mesg) = (@_);

  my $package;
  my $filename;
  my $line;

  ($package, $filename, $line) = caller;

  if( $result ) {
    ++ $testPasses;
    print "ok ", ++ $testNum, "\n";
  } else {
    ++ $testFailures;
    print "not ok ", ++ $testNum, "\n";
    print "FAIL: $filename:$line - $mesg\n";
  }
}

TestIt( ! ($cfgError = App::Debug::Configure( OUTLEVEL => \$debug)), $cfgError );

Debug( 1, "Debug message" );

print "TESTING DUMP HASH\n";
{
  my %testHash;

  $testHash{ one } = { subone => "subone",
		       down => { value => "ignore" },
		       subtwo => "subtwo"
		     };
  $debug = 3;
  DebugDumpHash( 0, "TEST", \%testHash, "down" );
  print "DUMP HASH COMPLETE\n";
  TestIt( 1 );
}

#
# End of Tests
#
if( $testFailures ) {
  print "$testFailures Tests FAILED ($testPasses PASSED)\n";
  exit( 1 );
} else {
  print "All $testPasses tests passed.";
  exit( 0 );
}



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


our %Doc;
$Doc{ File }	=   "test.pl";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "Script to regression test this module.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "05/30/01 09:36";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";

$Doc{ VERSION } = "+VERSION+";

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Text::Fill qw(fill);
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
my $debug = 1;

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

{
  my $paras = "
Here are a couple of paragraphs to fill and wrap with
the Text::Fill::fill() function.
each paragraph is separated by a '\\n\\s*\\n' sequence and special
code sections that are indented as compared to the
rest of the text are not wrapped. Here is a non wrapped snippet:

    my \$var;
    foreach \$var (split(/\s/,\"these are words to use\" )) {
      print \"\$var\";
    }";


  my $text = fill( 8, 8, 75, $paras );
  # print $text;

  my $expect = 
"        Here are a couple of paragraphs to fill and wrap with the
        Text::Fill::fill() function. each paragraph is separated by a
        '\\n\\s*\\n' sequence and special code sections that are indented as
        compared to the rest of the text are not wrapped. Here is a non
        wrapped snippet:

            my \$var;
            foreach \$var (split(/s/,\"these are words to use\" )) {
              print \"\$var\";
            }

";
  if( $text ne $expect ) {
    my $got = $text;
    my $want = $expect;
    my $pos = 0;
    print " Len: ", length( $got )," ", length( $want ), "\n";
    while( length( $got ) && length( $got ) == length( $want ) ) {
      my $g;
      my $w;
      $got =~ s/^(.)//mx;
      $g = ord $1;
      $want =~ s/^(.)//mx;
      $w = ord $1;
      print "'$g' ?= '$w' ", length( $got )," ", length( $want ), "\n"
	if debug;
      ++ $pos;
      if( $g ne $w ) {
	print "diff at $pos '$g' != '$w'\n" if $debug;
	last;
      }
    }
  }
  TestIt( $text eq $expect, "\nGot:\n$text\nExpected\n$expect" );
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
  


eval 'exec perl -W $0 ${1+"$@"}'
    if 0 ;
use strict;
use warnings;

package ChangeJavaPackage;
our %Doc;
$Doc{ File }	=   "ChangeJavaPackage.pl";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = " ";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "07/18/01 07:20";

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

   [ "version",		undef,
			"",	    "opt",
			"Show version and exit.",
			"Output the program's version information"
			." then exit" ],
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

   [ "from=s",		undef,
			"NAME",		"req",
			"original package name",
			"the package name to change" ],

   [ "to=s",		undef,
			"NAME",		"req",
			"new package name",
			"the name to change 'from' to".],

   [ "files@-",		undef,
			"file ...",	"req",
			"java sources",
			"the java sources to change the package in" ]
  );

use Doc::Self;
use App::Options;
use App::Debug;

use IO;


sub main {

  # $App::Options::debug = 1;
  my $doc   = new Doc::Self( DOC => \%Doc,
			     OPTIONS => \@Options );
  my $opts  = new App::Options( DOCSELF => $doc,
				OPTIONS => \@Options );

  foreach my $fn (@{$opts->opt( 'files' )}) {
    rename( $fn, "$fn.bak" )
      || die( "rename $fn to $fn.bak - $!" );

    my $in = IO::File( "< $fn.bak" );

    if( ! defined( $in ) ) {
      die "open $fn.back - $!";
    }

    my $out = IO::File( "> $fn" );
    if( ! defined( $out ) ) {
      die "open $fn - $!";
    }

    while( <$in> ) {
      s/(import|package)(\s+$from)/$1 $to/;
      print $out;
    }
}

$Doc{ "EXTRA_SECTIONS" } = [""];

$Doc{ "See Also" } = [""];

$Doc{ Files } = [""];

if( ! defined( $main::DontRun ) || $main::DontRun == 0 ) {
  main();
} else {
  1;
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
  

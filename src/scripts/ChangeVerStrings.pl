eval 'exec perl -W $0 ${1+"$@"}'
    if 0 ;
use strict;
use warnings;

package ChangeVerStrings;

our %Doc;
$Doc{ File }	=   "ChangeVerStrings.pl";
$Doc{ Project } =   ["PerlUtils",""];
$Doc{ Item }   	=   "";
$Doc{ desc } = "Change Dimention version strings to Cvs and visa vera";

$Doc{ Description } = "


";

$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "04/22/03 17:43";

$Doc{ Last_Mod_By } = '$Author$ ';
$Doc{ Last_Mod }    = '$Date$ ';
$Doc{ Ver }	    = '$Revision$ ';
$Doc{ Status }	    = '$State$ ';

$Doc{ VersionId }
  = '$Id$ ';

$Doc{ VERSION } = "1.00";

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

   [ 'files@-',		undef,
			"file ...",	"req",
			"file(s) to change",
			"The file to change the version tags in" ]

  );

use Doc::Self;
use App::Options;
use App::Debug;

use IO::File;


sub main {

  # $App::Options::debug = 1;
  my $doc   = new Doc::Self( DOC => \%Doc,
			     OPTIONS => \@Options );
  my $opts  = new App::Options( DOCSELF => $doc,
				OPTIONS => \@Options );


  foreach my $fn (@{$opts->opt( 'files' )}) {
    rename( $fn, "$fn.bak" )
      || die( "rename $fn to $fn.bak - $!" );

    my $in = new IO::File( "< $fn.bak" );

    if( ! defined( $in ) ) {
      die "open $fn.bak - $!";
    }

    my $out = new IO::File( "> $fn" );
    if( ! defined( $out ) ) {
      die "open $fn - $!";
    }

    my $hasPerlDoc = 0;
    while( <$in> ) {
      if( /^(.*)Last Mod By:\s+\%PO\%/ ) {
	$out->print( $1,'$Author$ ',"\n" );

      } elsif( /^(.*)Last Mod:\s+\%PRT\%/ ) {
	$out->print( $1,'$Date$ ',"\n" );

      } elsif( /^(.*)Version:\s+\%PIV\%/ ) {
	$out->print( $1, '$Name$ ',"\n",
	       $1, '$Revision$ ',"\n" );

      } elsif( /^(.*)Status:\s+\%PS\%/ ) {
	$out->print( $1, '$State$ ',"\n" );

      } elsif( /\%PI\%/ ) {
	# skip
      } elsif( $hasPerlDoc ) {
	s/\%PP\%//;
	s/\(?\%PF\%\)?//;
	s/\"\%PO\%\"/\'\$Author$ \'/;
	s/\"\%PRT\%\"/\'\$Date$ \'/;
	s/^(.*)\"\%PIV\%\"/$1\'\$Revision$ \';\n\$Doc\{ VerTag \}\t    = \'\$Name$ \'/;
	s/\"\%PS\%\"/\'\$State$ \'/;
	s/\"\%PID\%\"/\'\$Id$ \'/;
	$out->print( $_ );
      } elsif( /\$Doc/ ) {
	$hasPerlDoc = 1;
	$out->print( $_ );
      } else {
	s/\%PP\%//;
	s/\%PI\%//;
	s/\(?\%PF\%\)?//;
	s/\%PO\%/\$Author$ /;
	s/\%PRT\%/\$Date$ /;
	s/^(.*)\%PIV\%/$1\$Name$\n$1\$Revision$ /;
	s/\%PS\%/\$State$ /;
	s/\%PID\%/\$Id$/;
	$out->print( $_ );
      }
    }
  }
}

$Doc{ "EXTRA_SECTIONS" } = [""];

$Doc{ "See Also" } = ["cvs"];

$Doc{ Files } = [""];

if( ! defined( $main::DontRun ) || $main::DontRun == 0 ) {
  main();
} else {
  1;
}

our %Doc;
$Doc{ File }	=   "Makefile.PL";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "Use MakeMaker to generate a Makefile for this module.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
$Doc{ Created } = "05/30/01 13:27";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";

$Doc{ VERSION } = "+VERSION+";

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'ParseCxx',
    'VERSION_FROM'	=> 'ParseCxx.pm', # finds $VERSION
    'PREREQ_PM'		=> { Text::Tabs => 98.112801,
			     File::Basename => "2.6",
			     App::Debug => "1.01" },
);



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

our %Doc;
$Doc{ File }	=   "Makefile.PL";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc }	= "Use MakeMaker to generate a Makefile for this module.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

";
$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
$Doc{ Created } = "05/30/01 08:55";

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
    'NAME'		=> 'App::Options',
    'VERSION_FROM'	=> 'Options.pm', # finds $VERSION
    'PREREQ_PM'		=> { App::Debug => "1.01",
			     Getopt::Long => "2.23" },
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
  

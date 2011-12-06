use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$Doc{ File }	=   "Makefile.PL";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "Use MakeMaker to generate a Makefile for this module.";

$Doc{ Description } = "


";
$Doc{ Notes } = "

";

$Doc{ Author } =  [["Paul Houghton","<paul4hough\@gmail.com>"]];
$Doc{ Created } = "05/30/01 06:32";

$Doc{ Last_Mod_By } = "%PO%";
$Doc{ Last_Mod }    = "%PRT%";
$Doc{ Ver }	    = "%PIV%";
$Doc{ Status }	    = "%PS%";

$Doc{ VersionId }
  = "%PID%";


WriteMakefile(
    'NAME'		=> 'App::Debug',
    'VERSION_FROM'	=> 'Debug.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
);

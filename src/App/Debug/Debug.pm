package App::Debug;
require 5.006_001;
use strict;
use warnings;


eval 'exec perl -W $0 ${1+"$@"}'
    if 0 ;
use strict;
use warnings;

our %Doc;
$Doc{ File }	=   "Debug.pm";
$Doc{ Project } =   ["PerlUtils","INFR_OBJS"];
$Doc{ Item }   	=   "PU010C_APP_DEBUG_DEBUG_PM (PERL)";
$Doc{ desc } = "Functions to generate Debug output from perl scripts";

$Doc{ Description } = "


";
$Doc{ Notes } = "

";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "05/30/01 06:34";

$Doc{ Last_Mod_By } = "HOUGHTON";
$Doc{ Last_Mod }    = "30-MAY-2001 09:48:38";
$Doc{ Ver }	    = "1";
$Doc{ Status }	    = "INT IMPL";

$Doc{ VersionId }
  = "INFR_OBJS:PU010C_APP_DEBUG_DEBUG_PM.A-SRC;1";

$Doc{ VERSION } = "+VERSION+";


require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use App::Debug ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
#	
# ) ] );

# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( &Debug
		  &DebugDumpHash
);

our $VERSION = '1.01';

# Preloaded methods go here.

our $defaultOutLevel = 0;
our $OutputLevel = \$defaultOutLevel;
our $OutputIO = \*STDERR;
our $debug = 0;

use File::Basename;

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

App::Debug - Perl extension for blah blah blah

=head1 SYNOPSIS

  use App::Debug;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for App::Debug, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, a.u.thor@a.galaxy.far.far.away

=head1 SEE ALSO

perl(1).

=cut

sub Configure (%) {
  my (@param) = (@_);

  # print "PARAM: @param\n";
  if( ! ref($param[0]) eq "HASH" ) {
    return( "\nERROR: config argument is not a hash." );
  } else {
    # print "IS A HASH\n";
  }

  my %cfg = @param;
  # print "CFG: '%cfg'\n";
  my $p;
  my $errString;
  foreach $p (keys(%cfg)) {
    if( $debug ) {
      print STDERR "CONFIG: '$p' '$cfg{ $p }' '${$cfg{ $p }}'\n";
    }
    if( $p eq "OUTLEVEL" ) {
      $OutputLevel = $cfg{ $p };
    } elsif( $p eq "DEST" ) {
      $OutputIO = $cfg{ $p };
    } else {
      $errString .= "\nERROR: unknown App::Debug cfg option '$p'";
    }
  }
  return( $errString );
}

sub Debug ($@) {
  my ($level, @rest) = (@_);

  # print "L: '$level' '$OutputLevel' '$$OutputLevel'\n";
  if( $level <= $$OutputLevel ) {
    my ($pkg, $fn, $ln) = caller;
    if( $fn =~ /(.*) \(autosplit [^\)]+\)/ ) {
      $fn = $1;
    }
    $fn = basename( $fn );
    print $OutputIO "DEBUG($level) $fn:$ln:",@rest,"\n";
  }
}


sub DebugDumpHash ($$$@) {
  local $dbgLevel   = shift( @_ );
  local $prefix	    = shift( @_ );
  local $hash	    = shift( @_ );
  local @ignore	    = (@_);

  if( $dbgLevel <= $$OutputLevel ) {
    DumpHashTo( $OutputIO, $prefix, $hash, @ignore );
  }
}


sub DumpHash ($$@) {
  local $prefix	    = shift( @_ );
  local $hash	    = shift( @_ );
  local @ignore	    = (@_);

  DumpHashTo( \*STDOUT, $prefix, $hash, @ignore );
}

sub DumpHashTo ($$$@) {
  local $destIO	    = shift( @_ );
  local $prefix	    = shift( @_ );
  local $hash	    = shift( @_ );
  local @ignore	    = (@_);

  local $k;
  local $skip = "";

  # print "DUMPING HASH: '$dbgLevel' '$prefix' '$hash' '@ignore'\n";

  if ( $ignore[0] ) {
    if ( ref( $ignore[0] ) eq "ARRAY" ) {
      # print "is ref\n";
      $skip = join(" ",@$ignore );
    } else {
      # print "not ref\n";
      $skip = join(" ",@ignore );
    }
  }
  # print "SKIP: '$skip'\n";
  foreach $k (keys(%$hash)) {


    if ( $skip !~ /$k/ ) {
      if( ref( $$hash{ $k } ) eq "HASH" ) {
	DumpHashTo( $destIO, "$prefix:$k", $$hash{ $k }, $skip );
      } else {
	print $destIO "HASH: $prefix:$k: '$$hash{ $k }'\n";
      }
    }
  }
}


#
# Revision Log:
#
# Revision 1 (INT IMPL)
#   Created:  30-MAY-2001 09:49:02 HOUGHTON
#     Initial Implementation
#

# Set XEmacs mode
#
# Local Variables:
# mode:perl
# End:
  


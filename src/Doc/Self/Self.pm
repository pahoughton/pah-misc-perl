package Doc::Self;
require 5.6.0;
use strict;
use warnings;

our %Doc;
$Doc{ File }	=   "Self.pm";
$Doc{ Project } =   ["PerlUtils","%PP%"];
$Doc{ Item }   	=   "%PI% (%PF%)";
$Doc{ desc } = "Provides complete self documentation of Perl Scripts";

$Doc{ Description } = "


";
$Doc{ Notes } = "

   For the rest of this programs documentation, either run it
   with -man or see `Detailed Documentation' below.
";
$Doc{ Author } =  [["Paul Houghton","<paul.houghton\@wcom.com>"]];
$Doc{ Created } = "05/30/01 09:07";

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

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Doc::Self ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
#	
# ) ] );

# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '1.01';

# Preloaded methods go here.

our( $debug );
our( $TermCols, $TermRows );


sub new ($%);
sub usage ($$$);
sub usageError( $@ );

sub getUsageText ($$);
sub bold ($$);
sub synopsys ($);
sub optString ($$$$);
sub initialize (@);
# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

use Text::Tabs qw(expand unexpand);
use Text::Fill qw(fill);
use File::Basename;
use Term::Size;
use App::Debug;
use Config;
use Carp;

sub new ($%) {
  my ($this, %params) = (@_);

  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;

  if( ! defined( $params{ DOC } ) ) {
    croak( "required param `DOC' not provided to Doc::Self." );
  }

  {
    my $unknown;
    my $p;
    foreach $p (keys(%params)) {
      print "Param: $p\n" if $debug;
      if( $p eq "DOC" ) {
	$$self{ doc } = $params{ $p };
      } elsif( $p eq "OPTIONS" ) {
	$$self{ options } = $params{ $p };
      } elsif( $p eq "ENV" ) {
	$$self{ env } = $params{ $p };
      } elsif( $p eq "DEBUG" ) {
	$$self{ debug } = 1;
      } else {
	print "Unknown arg '$p' passed to Doc::Self\n";
	$unknown = 1;
      }
    }
    if( $unknown ) {
      croak( "Aborted for uknown Doc::Self parameter." );
    }
  }

  if( ! $TermRows ) {
    ( $TermCols, $TermRows ) = Term::Size::chars();
  }

  $$self{ outwidth } = ($TermCols > 10 ? $TermCols - 5 : 75 );
  $$self{ outrows } = $TermRows;

  $$self{ prog } = basename( $main::0 );

  # $self->initialize();
  return $self;

}

sub initialize (@) {
  my ($class) = (@_);

}

sub optString ($$$$) {
  my ($class, $opt, $arg, $req) = (@_);

  my $optName;
  my $optType;

  my $optText;

  # print "Createing opt string '$opt' '$arg' '$req'\n";

  if ( $req !~ /^req/i ) {
    $optText .= "[";
  }
	
  if ( $opt ) {
    if( $opt =~ /([-\w]+)(\|[-\|\w]+)*[@]*-$/ ) {
      if( $arg ) {
	$optText .= $arg;
      }
    } elsif ( $opt !~
	      /^((\w+[-\w]*)(\|(\?|\w[-\w]*)?)*)?([!+]|[=:][infse][@%]?)?$/ ) {
      confess( "ERROR: Invalid option spec: '$opt'\n" );
    } else {
      $optName = $1;
      $optType = $5;


      # print "OPT: '$optName' '$optType'\n";
      if ( $optType ) {
	if ( $optType eq "!" ) {
	  $optText .= "-\[no\]$optName";
	} else {
	  $optText .= "-$optName";
	  if ( $optType eq "+" ) {
	    $optText .= "[-$optName]";
	  } else {
	    my $mand;
	  ($mand,$optType) = $optType =~ /(.)(.)/;

	    if ( $mand eq ":" ) {
	      $optText .= " [";
	    }

	    if ( $arg ) {
	      $optText .= " $arg";
	    } else {
	      if ( $optType eq "s" ) {
		$optText .= " string";
	      } elsif ( $optType eq "i" ) {
		$optText .= " int";
	      } elsif ( $optType eq "f" ) {
		$optText .= " float";
	      }
	    }

	    if ( $mand eq ":" ) {
	      $optText .= "]";
	    }
	  }
	}
      } else {
	$optText .= "-$optName";
      }
    }
  } elsif ( $arg ) {
    $optText .= $arg;
  } else {
    return( "ERROR: no opt or arg given." );
  }

  if ( $req !~ /^req/i ) {
    $optText .= "]";
  }
  return( $optText );
}

sub synopsys ($) {
  my ($self) = (@_);

  my $optLine;
  my $optLineLen = 0;

  $optLine = "$$self{ prog } ";
  $optLineLen = length( $optLine ) + 4;

  foreach $o (@{$$self{ options }} ) {
    my $optText = $self->optString( $$o[0], $$o[2], $$o[3] );
    # print "DEBUG: '$optText'\n";

    my $optLen = length( $optText );

    if ( ($optLineLen + $optLen) > $$self{ outwidth } ) {
      $optLineLen = $optLen + 9;
      $optLine .= "\n        $optText ";
    } else {
      $optLineLen += $optLen + 1;
      $optLine .= "$optText ";
    }
    $optText = "";
  }
  return( $optLine );
}

sub bold ($$) {
  my ($self, $text) = (@_);

  $text =~ s/(.)/$1\010$1/g;
  return( $text );
}

sub getUsageText ($$) {
  my ($self, $level) = (@_);

  my $usageText;

  if( $level <= 1 ) {
    $usageText .= "\n$$self{ prog } - $$self{ doc }->{ desc }\n\n";
    $usageText .= "    " . $self->synopsys() ."\n";
  } elsif ( $level == 2 ) {
    my $optWidth = 0;
    my @opts;
    foreach $o (@{$$self{ options }} ) {
      my $optText = $self->optString( $$o[0], $$o[2], $$o[3] );
      push(@opts,$optText);
      my $optLen = length( $optText );
      if( $optLen > $optWidth ) {
	$optWidth = ( $optLen > 20 ? 20 : $optLen );
      }
    }

    $usageText .= "\n$$self{ prog } - $$self{ doc }->{ desc }\n\n";
    for( $i = 0; $opts[$i]; ++ $i ) {
      # print "OPT: $opts[$i] ($optWidth) \n";
      # print "$$self{ options }[$i][3]\n";
      my $optDesc = fill( $optWidth + 2,
			  $optWidth + 2,
			  $$self{ outwidth },
			  $$self{ options }[$i][ 4 ] );
      # print "DESC: $optDesc\n";
      if( length( $opts[$i] ) > $optWidth ) {
	$usageText .= " $opts[$i]\n";
	$usageText .= $optDesc;
      } else {
	substr( $optDesc, 1, length( $opts[$i] ) ) = $opts[$i];
	$usageText .= "$optDesc";
      }
    }
  } elsif( $level == 3 ) {
    my $optWidth = 0;
    my @opts;
    foreach $o (@{$$self{ options }} ) {
      my $optText = $self->optString( $$o[0], $$o[2], $$o[3] );
      push(@opts,$optText);
      my $optLen = length( $optText );
      if( $optLen > $optWidth ) {
	$optWidth = ( $optLen > 20 ? 20 : $optLen );
      }
    }

    $usageText .=
      "\n$$self{ prog } " .
      "- $$self{ doc }->{ Version } " .
      "- $$self{ doc }->{ Last_Mod }\n\n";

    $usageText .= fill( 1, 1, $$self{ outwidth },
			$$self{ doc }->{ Description } ) ."\n";

    for( $i = 0; $opts[$i]; ++ $i ) {
      my $optDesc = fill( $optWidth + 2,
			  $optWidth + 2,
			  $$self{ outwidth },
			  $$self{ options }[ $i ][ 5 ] );
      if( length( $opts[$i] ) > $optWidth ) {
	$usageText .= " $opts[$i]\n";
	$usageText .= $optDesc;
      } else {
	substr( $optDesc, 1, length( $opts[$i] ) ) = $opts[$i];
	$usageText .= "$optDesc";
      }

    }
  } else {
    my $optWidth = 0;
    my @opts;
    my @envVars;
    foreach $o (@{$$self{ options }} ) {
      my $optText = $self->optString( $$o[0], $$o[2], $$o[3] );
      push(@opts,$optText);
      my $optLen = length( $optText );
      if( $optLen > $optWidth ) {
	$optWidth = ( $optLen > 20 ? 20 : $optLen );
      }

      if( defined( $$o[6] ) ) {
	if( ref( $$o[6] ) eq "ARRAY" ) {
	  # print "ENV is ARRAY\n";
	  my $env;
	  foreach $env (@{$$o[6]}) {
	    push( @envVars, [ $env, "Used for option `$optText'" ] );
	  }
	} else {
	  push( @envVars, [ $$o[6], "Used for option `$optText'" ] );
	}
      }
    }
    $usageText .= "
" . $self->bold( "NAME" ) ."

    $$self{ prog } - $$self{ doc }->{ desc }

" . $self->bold( "SYNOPSYS" ) . "

";
    $usageText .= "    " . $self->synopsys() . "\n\n";
    $usageText .= $self->bold( "DESCRIPTION" )."\n\n";
    $usageText .= fill( 4, 4, $$self{ outwidth },
			$$self{ doc }->{ Description } );

    $usageText .= $self->bold( "OPTIONS" )."\n\n";

    for( $i = 0; $opts[$i]; ++ $i ) {
      my $optDesc = fill( $optWidth + 6,
			  $optWidth + 6,
			  $$self{ outwidth },
			  $$self{ options }[ $i ][ 5 ] );

      if( length( $opts[$i] ) > $optWidth ) {
	$usageText .= "    $opts[$i]\n";
	$usageText .= $optDesc;
      } else {
	substr( $optDesc, 4, length( $opts[$i] ) ) = $opts[$i];
	$usageText .= "$optDesc";
      }
    }

    if( defined( $$self{ doc }->{ "EXTRA_SECTIONS" } ) ) {
      foreach $sect (@{$$self{ doc }->{ "EXTRA_SECTIONS" }}) {
	$usageText .= $self->bold( "$sect" )."\n\n";
	$usageText .= fill( 4, 4, $$self{ outwidth },
			    $$self{ doc }->{ $sect } )."\n\n";
      }
    }

    if( defined( $$self{ env } ) || @envVars ) {
      $usageText .= $self->bold( "ENVIRONMENT" )."\n\n";
      my $e;
      my $envWidth = 0;
      foreach $e (@envVars) {
	my $envLen = length( $$e[0] );
	if( $envLen > $envWidth ) {
	  $envWidth = ($envLen > 20 ? 20 : $envLen );
	}
      }
      foreach $e (@{$$self{ env }}) {
	my $envLen = length( $$e[0] );
	print "ENV: $e[0]\n";
	push( @envVars, $e );
	if( $envLen > $envWidth ) {
	  $envWidth = ($envLen > 20 ? 20 : $envLen );
	}
      }
      print "ENV W: $envWidth\n";
      my $env;
      foreach $env (@envVars) {
	my $envDesc = fill( $envWidth + 6,
			    $envWidth + 6,
			    $$self{ outwidth },
			    $$env[ 1 ] );
	if( length( $$env[0] ) > $envWidth ) {
	  $usageText .= "    $$env[0]\n";
	  $usageText .= $envDesc;
	} else {
	  substr( $envDesc, 4, length( $$env[0] )) = $$env[0];
	  $usageText .= $envDesc;
	}
      }
    }

    if( defined( $$self{ doc }->{ "See Also" } ) ) {
      $usageText .= $self->bold( "SEE ALSO" )."\n\n";
      my $see;
      my $seeText = "";
      foreach $see (@{$$self{ doc }->{ "See Also" }}) {
	$seeText .= "$$see[0]($$see[1]) ";
      }
      $usageText .= fill( 4, 4, $$self{ outwidth }, $seeText );
    }
	
    if( defined( $$self{ doc }->{ "Files" } ) ) {
      $usageText .= $self->bold( "FILES" )."\n\n";
      my $f;
      foreach $f (@{$$self{ doc }->{ Files }}) {
	$usageText .= "    $f\n";
      }
      $usageText .= "\n";
    }

    if( defined( $$self{ doc }->{ VERSION } ) ) {
      $usageText .= $self->bold( "VERSION" )."\n\n";
      $usageText .= "    $$self{ doc }->{ VERSION }";

      if( defined( $$self{ doc }->{ Last_Mod } ) ) {
	$usageText .= " - $$self{ doc }->{ Last_Mod }\n\n";
      } else {
	$usageText .= "\n\n";
      }
    }

    if( defined( $$self{ doc }->{ Author } ) ) {
      $usageText .= $self->bold( "AUTHOR" )."\n\n";
      foreach $a (@{$$self{ doc }->{ Author }} ) {
	$usageText .= "    " . $$a[0] . " - " . $$a[1] . "\n";
      }
      $usageText .= "\n\n";
    }
  }
  return( $usageText );
}

sub usage ( $$$ ) {
  my ($self, $level, $usePager) = (@_);

  $text = $self->getUsageText( $level );

  my @lines = split(/\n/,$text);
  # print "Rows: $TermRows\nLines: ".scalar(@lines)."\n";
  if( $usePager && $TermRows
      && (scalar(@lines) + 1) >= $TermRows ) {
    local($SIG{PIPE}) = "IGNORE";
    my $pager;
    if( $Config{ pager } ) {
      $pager = $Config{ pager };
    } else {
      $pager = "more";
    }
    open( OUT, "| $Config{ pager }" );
    print OUT $text;
    close OUT;
  } else {
    print $text;
  }
}

sub usageError ($@) {
  my ($self, @mesg) = (@_);
  $self->usage( 1, 1 );
  croak( "\nERROR: ",@mesg,"\n" );
}

# Below is stub documentation for your module. You better edit it!


=head1 NAME

Doc::Self - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Doc::Self;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Doc::Self, created by h2xs. It looks like the
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

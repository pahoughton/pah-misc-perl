#
# File:	    ParseCxx.pm
# Project:  PerlUtils %PP%
# Item:	    %PI% (%PF%)
# Desc:
#
#   Source for ParseCxx perl module.
#
# Notes:
#
#   See pod below for documentation
#
# Created:  5/30/01 13:28
# Author:   Paul Houghton <paul4hough@gmail.com>
#
# Revision Information
#
#   Last Mod By:    %PO%
#   Last Mod:	    %PRT%
#   Version:	    %PIV%
#   Status:	    %PS%
#
# %PID%
#
package ParseCxx;

require 5.006;
use strict;
use warnings;
use Text::Tabs;
use File::Basename;
use App::Debug;
use Carp;
use English;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use ParseCxx ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( &Parse
	
);

our $VERSION = '1.01';

our $debug = 0;

# Preloaded methods go here.

our $PARSE_NR;

our $commentSection;
# our $commentMainClass;
# our $prevSection;
our $commentSectionStartLineNum;

our $CNTX_CONSTRUCTOR_ARG_INIT = "cntx constructor arg init" ; # context value
our $CNTX_FUNC_BODY = "cntx function body";
# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

ParseCxx - C++ Header Parser

=head1 SYNOPSIS

  use ParseCxx;

=head1 DESCRIPTION


Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

Paul Houghton <paul4hough@gmail.com>

=head1 SEE ALSO

perl(1).

=cut

sub ParseHeaderInfo ($$) {
  my $in    = shift(@_);
  my $info  = shift(@_);

  my $inComment = 0;
  my $comment = "";
  my $section = "";
  my $gotHeader = 0;
    while( <$in> ) {
    # Debug( 5, "SRC: $_" );
    if( ! $inComment ) {
      if( m@/\*\s*(.*)@ ) {
	$rest = $1;
	if( $rest =~ m@(.*)\*/@ ) {
	  $comment = $1;
	} else {
	  $inComment = 1;
	  $comment = $rest;
	}
      }
      if( m@//(.*)@ ) {
	$comment = "$1";
	$comment =~ s/^\s+//;
	$comment =~ s/\s*$//;
	$comment .= "\n";
      }
    } else {
      if( m@\s*(.*)\*/@ ) {
	$comment = "$1";
	$comment =~ s/^\s+//;
	$comment =~ s/\s*$//;
	$comment .= "\n";
	$inComment = 0;
      } else {
	$comment = $_;
	$comment =~ s/^\s+//;
	$comment =~ s/\s*$//;
      }
    }

    if( length( $comment ) ) {
      # Debug( 5, "$comment" );
      if( $comment =~ m@^\s*(\w[^:]+):\s*(.*)@ ) {

	$section = $1;
	$text = $2;
	$section =~ s/^\s+//;
	$section =~ s/\s*$//;
	$text =~ s/^\s+//;
	$text =~ s/\s*$//;
	
	$$info{ $section } = "$text\n";
	# Debug( 5, "Found section: '$section'\n" );
	$gotHeader = 1;
      } else {
	if( length( $section ) ) {
	  $text = $comment;
	  $text =~ s/^\s+//;
	  $text =~ s/\s*$//;
	  $$info{ $section } .= "$text\n";
	}
      }
      $comment = "";
    } else {
      if( ! $inComment && $gotHeader ) {
	last;
      }
    }
  }
}

sub GetNested ($$$$$) {
  my $open  = shift( @_ );
  my $close = shift( @_ );
  my $text  = shift( @_ );
  my $dest  = shift( @_ );
  my $stripOpenClose = shift( @_ );

  Debug( 5, "GETNESTED '$$text'\n" );
  if( $$text =~ /^([^$open$close]*)($open)(.*)/s ) {
    if( ! $stripOpenClose ) {
      $$dest .= "$1$2"
    }
    $$text = $3;

    while( $$text =~ /^([^$open$close]*)($open)(.*)/s ) {
      if( ! GetNested( $open, $close, $text, $dest, 0 ) ) {
	return( 0 );
      }
    }

    Debug( 5, "LOOKING FOR CLOSE: '$close'\n" );
    if( $$text =~ /^([^$close]*)($close)(.*)/s ) {
      $$dest .= "$1";
      if( ! $stripOpenClose ) {
	$$dest .= "$2";
      }
      $$text = $3;
      Debug( 5, "FOUND CLOSE\n" );
      return( 1 );
    } else {
      return( 0 );
    }
  } else {
    return( 1 );
  }
}

sub ParseOpenBrace ($$$) {
  my $statement = shift(@_);
  my $info  = shift(@_);
  my $context = shift(@_);
  Debug( 5, "OPEN BRACE:\n'$statement'\n" );

  my $type;
  my $name;

  if( $statement =~ /(.*)\s*(class|struct)\s+(.*)/ ) {
    my $prefix;
    my $suffix;
    my $inheritace;
    $prefix = $1;
    $type = $2;
    $suffix = $3;
    if( $suffix =~ /(\w+)\s*:(.*)/ ) {
      $name = $1;
      $inheritance = $2;
    } else {
      $name = $suffix;
      $name =~ s/\s+$//;
      $inheritance = "";
    }

    ++ $$info{ typeNum };
    $$info{ "type" }->{ $$info{ typeNum } } = { "type" => "$type",
						name => "$name"
					      };

    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ name } = $name;
    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name } =
      {
       template		=> "",
       name		=> $name,
       type		=> $type,
       inheritance	=> $inheritance
      };

    if( defined( $$info{ TopLevel } ) && $$info{ TopLevel } == 1 ) {
      my $tmpFn = $$info{ filename };
      Debug( 4, "TOP LEVEL: class '$name' file '$tmpFn'\n" );
      if( $name eq basename( $tmpFn, (".hh",".h",".H") ) ) {
	$$info{ MainClass } =  {
				number => $$info{ typeNum },
				name => $name,
				type => $type
			       };
      }
    }
    my $prot;

    if( $type eq "class" ) {
      $prot = "private";
    } else {
      $prot = "public";
    }

    $down = $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name };
    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ $prot }
      = {
	 prot => $prot,
	 down => $down
	};

    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ down }
      = $info;

    Debug( 5, "$info\n" );
    Debug( 5, "$$info{ type }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ down }\n" );
    Debug( 5, "$$info{ type }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ $prot }\n" );
    Debug( 5, "$$info{ type }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ $prot }->{ down }\n" );

    return( $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name }->{ $prot } );
  } elsif ( $statement =~ /(.*)\s*(enum)\s+(.*)/ ) {
    my $prefix = $1;
    my $name = $3;
    Debug( 4, "ENUM: '$name' $statement \n" );
    $name =~ s/\s+//g;
    $type = "enum";

    ++ $$info{ typeNum };
    $$info{ "type" }->{ $$info{ typeNum } } = { "type" => $type,
					      name => $name
					    };
    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ name } = $name;
    $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name } =
      {
       name		=> $name,
       type		=> $type,
       down		=> $info,
       enumNum		=> 0
      };
    return( $$info{ "type" }->{ $$info{ typeNum } }->{ $type }->{ $name } );
  } else {
    $info = ParseStatement( $statement, $info, $context );
    $$context = $CNTX_FUNC_BODY;
    return( $info );
  }
}

sub ParseStatement ($$$) {
  my $statement = shift(@_);
  my $info	= shift(@_);
  my $context	= shift( @_ );
  Debug( 5, "STATEMENT:\n'$statement'\n" );
  my $return;
  my $args;
  my $rest;

  Debug( 5, "CONTEXT: $$context\n" );
  if( $$context eq $CNTX_FUNC_BODY ) {
    return( $info );
  }

  my $funcName = "";
  my $sig;


  my $pre;
  my $nested = undef;

  if( $statement =~ /\(\s*\*\s*\w+\s*\)\s*\([^\)]+\)/ ) {
    # pointer to a function variable
    # FIXME JUST BLOW IT OFF
    return( $info );
  }

  if( $statement =~ /([^\(]*operator[^\(]+\(\s*\))(\s+\(.*)$/s ) {
    $pre = $1;
    $rest = $2;
    GetNested( '\(','\)',\$rest, \$nested, 1 );
  } elsif( $statement =~ /([^\(]*operator[^\(]+)(\(\s*\))(.*)/s ) {
    $pre = $1;
    $nested = " ";
    $rest = $3;
  } elsif( $statement =~ /([^\(]*)(\(.*)/s ) {
    $pre = $1;
    $rest = $2;
    GetNested( '\(','\)',\$rest, \$nested, 1 );
  }

  if( $nested ) {

    Debug( 3, "STMT GN:\n pre: '$pre' \n nest:'$nested'\n rest:'$rest'" );

    if( $pre =~ /(.*)(operator.*)$/ ) {
      $return = $1;
      $funcName = $2;
      $sig = $nested;
    } elsif ( $pre =~ /(.*)\s+(~?\w+)\s*$/ ) {
      $return = $1;
      $funcName = $2;
      $sig = $nested;
    } elsif ( $pre =~ /\s*(~?\w+)\s*$/ ) {
      $funcName = $1;
      $sig = $nested;
    } else {
      confess( "PARSE ERROR: func '$statement'" );
    }
  }


  if ( length(  $funcName ) ) {
    if( $return && $return =~ /friend(.*)/ ) {
      $return = $1;
      $return =~ s/^\s+//;
      my $topInfo = $info;
      while( defined( $$topInfo{ down } ) ) {
	$topInfo = $$topInfo{ down };
      }
      if( defined( $$topInfo{ MainClass } ) ) {
	StoreFunc( $return, $funcName, $sig, $rest, $topInfo );
      } else {
	DebugDumpHash( 3, "TOP", $topInfo, "down" );
	confess "could not find Top Level info.";
      }
    } else {
      StoreFunc( $return, $funcName, $sig, $rest, $info );
    }
  } else {

    if( $statement =~ /typedef\s+(.*)\s+(\w+)$/ ) {
      my $src = $1;
      my $type = $2;

      ++ $$info{ typeNum };
      $$info{ "type" }->{ $$info{ typeNum } } = { "type" => "typedef",
						name => "$type"
					      };

      $$info{ "type" }->{ $$info{ typeNum } }->{ typedef }->{ "$type" } =
	{
	 name	    => $type,
	 src	    => $src
	};
    } elsif( $statement =~ /^\s*static\s+const\s+([\w\s\*\&]+)\s+(\w+)$/ ) {
      my $type = $1;
      my $var = $2;
      ++ $$info{ static_constNum };
      $$info{ static_const }->{ $$info{ static_constNum } } =
	{
	 name	=> $var,
	 type	=> $type
	};
      Debug( 1, "STATIC CONST VAR: '$var' '$type'\n" );
    } elsif ( $statement =~ /^\s*friend/ ) {
      Debug( 6, "SKIPPING FRIEND: $statement\n" );
    } elsif( $statement =~ /^\s*(\w[\w\s]+)(\*|\&)*\s+(\w+)$/ ) {
      my $tname = $1;
      my $tmod = $2;
      my $type;
      if( $tname ) {
	$type = $tname;
      }
      if( $tmod ) {
	$type .= $tmod;
      }
      my $var = $3;
      ++ $$info{ varNum };
      $$info{ variable }->{ $$info{ varNum } } =
	{
	 name	=>  $var,
	 type	=>  $type
	};
    } else {
      Debug( 1, "UNPROCESSED STATEMENT: '$statement'\n" );
    }
  }

  return( $info );
}

sub ParseLabel ($$$) {
  my $statement = shift(@_);
  my $info  = shift(@_);
  my $context = shift(@_);

  Debug( 5, "LABEL:\n'$statement'\n" );

  Debug( 5, "$info\n" );
  my $type;
  if( $statement =~ /^\s*(public|protected|private)\s*$/ ) {
    $type = $1; 
    Debug( 5, "$$info{ down }\n" );
    DebugDumpHash(  3, "LABEL", $info , "down" );
    $info = $$info{ down };
    $$info{ $type } = { prot => "$type",
		       down => $info
		      };
    $info = $$info{ $type };
    DebugDumpHash(  3, "LABEL", $info , "down" );

  }
  if( $statement =~ /^\s*([^\(]+)\s+(\w+)\s*\(([^\)]*)\)(.*)$/ ) {
    $return =  $1;
    $funcName = $2;
    $sig = $3;
    $rest = $4;
    StoreFunc( $return, $funcName, $sig, $rest, $info );
    $$context = $CNTX_CONSTRUCTOR_ARG_INIT;
  }

  Debug( 5, "$info\n" );
  return( $info );
}

sub ParseCloseBrace ($$$) {
  my $statement = shift(@_);
  my $info  = shift(@_);
  my $context = shift(@_);

  Debug( 5, "CLOSE BRACE:\n'$statement'\n" );
  Debug( 5, "CONTEXT: $$context\n" );

  if( $$context eq $CNTX_FUNC_BODY ) {
    $$context = "decl";
    Debug( 5, "CONTEXT: $$context\n" );
    return( $info );
  }

  if( $$info{ prot } ) {
    Debug( 5, "$info\n" );
    Debug( 5, "$$info{ down }->{ down }\n" );
    return( $$info{ down }->{ down } );
  } elsif ( $$info{ "type" } eq "enum" ) {
    Debug( 4, "ENUM: $statement\n");
    my $e;
    foreach $e (split(/,/,$statement)) {
      my $ename;
      my $eval;
      if( $e =~ /\s*(\w+)\s*=\s*(.*)$/ ) {
	$ename = $1;
	$eval = $2;
      } else {
	$ename = $e;
	$eval = "";
      }
      $ename =~ s/\s+//g;
      $eval =~ s/^\s+//g;
      $eval =~ s/\s+$//g;
      $$info{ ++$$info{ enumNum } } = { name => $ename,
					val => $eval
				      };
    }
    return( $$info{ down } );
  } else {
    return( $info );
  }

}

sub StoreFunc ($$$$$) {
  my $return	= shift(@_);
  my $name	= shift(@_);
  my $sig	= shift(@_);
  my $rest	= shift(@_);
  my $info	= shift(@_);

  Debug( 5, "StoreFunc( $return, $name, $sig, $rest )" );
  my @args;
  my $funcTmpl;
  my $funcType;
  my $funcRet;
  my $funcConst;
  my $funcPurVirtual;

  $sig =~ s/^\s+//;
  $sig =~ s/\s+$//;
  $sig =~ s/\s+/ /g;
  if( length( $sig ) == 0 ) {
    $sig = "void";
  }

  $name =~ s/^\s+//;
  $name =~ s/\s+$//;
  $name =~ s/\s+/ /g;

  if( $return =~ /template/ ) {
    my $tmplArgs;
    GetNested( '<','>',\$return, \$tmplArgs, 0 );
    $funcTmpl = "$tmplArgs";
    $funcTmpl =~ s/^\s+//;
    $funcTmpl =~ s/\s+$//;
  } else {
    $funcTmpl = "";
  }

  if( $return =~ /(virtual|inline|static)\s*(.*)/ ) {
    $funcType = $1;
    $funcRet = $2;
  } else {
    $funcType = "";
    $funcRet = $return;
  }
  if( $rest =~ /const/ ) {
    $funcConst = "const";
  } else {
    $funcConst = "";
  }

  if( $rest =~ /=\s*0/ ) {
    $funcPurVirtual = "= 0";
  } else {
    $funcPurVirtual = "";
  }

  $funcType =~ s/^\s+//;
  $funcType =~ s/\s+$//;

  $funcRet =~ s/^\s+//;
  $funcRet =~ s/\s+$//;

  Debug( 5, "FOUND FUNCT: $name $sig\n
  tmpl: '$funcTmpl'
  type: '$funcType'
   ret: '$funcRet'
  name: '$name'
  args: '$sig'
  cons: '$funcConst'
  virt: '$funcPurVirtual'\n" );

  ++ $$info{ funcNum };
  $$info{ func }->{ $$info{ funcNum } } =
    {
     tmpl	=> $funcTmpl,
     type	=> $funcType,
     ret	=> $funcRet,
     name	=> $name,
     args	=> $sig,
     const	=> $funcConst,
     virt	=> $funcPurVirtual,
     desc	=> ""
    };
  {
    my $a;
    my @argList;
    foreach $a (split( /,/, $sig )) {
      if( $a =~ /void/ ) {
	push( @argList,{ "type" => "void",
			 name => "",
			 default => ""
		       } );
      } elsif( $a =~ /\s*(.*)\s+(\w+)\s*=\s*(.*)\s*$/ ) {
	push( @argList,{ "type" => "$1",
			 name => "$2",
			 default => "$3"
		       } );	
      } elsif( $a =~ /\s*(.*)\s+(\w+)\s*$/ ) {
	push( @argList, { "type" => $1,
			  name => $2,
			  default => ""
			} );
      } else {
	push( @argList, { "type" => $a,
			  name => "",
			  default => ""
			} );
      }
    }
    $$info{ func }->{ $$info{ funcNum } }->{ arglist } = \@argList;

    # Debug( 0, "@argList );
  }
	
  return( $$info{ func }->{ $$info{ funcNum } } );
}

sub FindInnerClass {
  my ( $info, $inClasses ) = (@_);

  my $type = $$info{ "type"
		   }->{ $$info{ MainClass }->{ number }
		      }->{ $$info{ MainClass }->{ "type" }
			 }->{ $$info{ MainClass }->{ name } };

  my $sc;
  my $foundSubclass = 0;
  my $subType = $type;
  Debug( 3, "Looking for inner class '$inClasses'" );
  foreach $sc (split(/::/,$inClasses)) {
    my $t;
    foreach $t (keys(%{$$subType{ "public" }->{ "type" }})) {
      if( $sc eq $$subType{ "public" }->{ "type" }->{ $t }->{ name } ) {
	$subType = $$subType{ "public"
			    }->{ "type"
			       }->{ $t
				  }->{ $$type{ "public"
					     }->{ "type"
						}->{ $t
						   }->{ "type" }
				     }->{ $sc };
	Debug( 3, "Found inner class '$subType'" );
	DebugDumpHash( 3, "FND INR", $subType, "down" );
	last;
      }
    }
  }
  if( $subType == $type ) {
    confess "ERROR: $$info{ filename }:$PARSE_NR inner type '$inClasses' not found."
  }
  Debug( 3, "Found inner class '$subType'" );
  return( $subType );
}


sub SetTypeDesc {
  my ( $info, $prot, $type, $name, $desc ) = (@_);

  if( ! defined( $name )
      || ! $name
      || $name eq $$info{ MainClass }->{ name } ) {
    return;
  }

  my $typeList;
  if( $name !~ /::/ ) {
    $typeList
      = $$info{ "type"
	      }->{ $$info{ MainClass }->{ number }
		 }->{ $$info{ MainClass }->{ "type" }
		    }->{ $$info{ MainClass }->{ name }
		       }->{ $prot }->{ "type" };
  } else {
    if( $name =~ /^(.*)::(\w+)$/ ) {
      my $inClasses = $1;
      $name = $2;
      my $type = FindInnerClass( $info, $inClasses );
      $typeList = $type{ $prot }->{ "type" };
    } else {
      die "IMPOSIBLE ! ::";
    }
  }

  my $t;
  my $found = 0;
  foreach $t (keys(%$typeList)) {
    if ( defined( $$typeList{ $t }->{ $type }->{ name } ) ) {
      Debug( 2, "'$name' ?= '$$typeList{ $t }->{ $type }->{ name }'" );

      if ( $name eq $$typeList{ $t }->{ $type }->{ name } ) {
	$found = 1;
	if ( $type eq "enum" ) {
	  # special treatment for enums the desc might
	  # list each enum with a desc
	  my $e;
	
	  foreach $e (keys(%{$$typeList{ $t }->{ $type }->{ $name }})) {
	    if ( defined( $$typeList{ $t
				    }->{ $type
				       }->{ $name
					  }->{ $e
					     }->{ name } ) ) {
	      my $enum = $$typeList{ $t
				   }->{ $type
				      }->{ $name
					 }->{ $e
					    }->{ name };
	      my $line;
	      my $indent;
	      my $text;
	      foreach $line (split(/\n/,$desc)) {
		if ( $line =~ /^(\s+$enum\s+)(\S.*)$/ ) {
		  # found a specific enum desc;
		  $indent = length( $1 );
		  $$typeList{ $t }->{ $type }->{ $name }->{ $e }->{ desc }
		    = "$2\n";
		} elsif ( defined( $indent )
			  && $line =~ / {$indent}(\S.*)/ ) {
		  $$typeList{ $t }->{ $type }->{ $name }->{ $e }->{ desc }
		    .= "$1\n";
		} elsif ( defined( $indent )
			  && $line =~ /^\s*$/ ) {
		  $$typeList{ $t }->{ $type }->{ $name }->{ $e }->{ desc }
		    .= "\n";
		} elsif ( defined( $indent ) ) {
		  $indent = undef;
		  $text .= "$line\n";
		} else {
		  $text .= "$line\n";
		}
	      }
	      Debug( 1, "ENUM(text): '$text'" );
	      $desc = $text;
	      $text = "";
	    }
	  }
	  Debug( 1, "ENUM($name): '$desc'" );
	  $$typeList{ $t }->{ $type }->{ desc } = $desc;
	} else {
	  $$typeList{ $t }->{ $type }->{ desc } = $desc;
	}
	last;
      }
    }
  }
  if( ! $found ) {
    DebugDumpHash( 0, "TYPE", $typeList, "down" );
    confess "Type '$prot' '$type' '$name' NOT found.";
  }
}

sub SetFuncDesc ($$$) {
  my $info	= shift( @_ );
  my $prot	= shift( @_ );
  my $desc	= shift( @_ );

  my $return = "";
  my $funcName = "";
  my $sig = "";
  my $rest = "";

  my $funcTmpl = "";
  my $funcType = "";
  my $funcRet = "";
  my $funcConst = "";
  my $funcPurVirtual = "";
  my $funcDesc = "";
  my $nested = "";

  if( $desc =~ /([^\(]*operator[^\(]+\(\s*\))(\s+\(.*)$/s ) {
    $pre = $1;
    $rest = $2;
    GetNested( '\(','\)',\$rest, \$nested, 1 );
  } elsif( $desc =~ /([^\(]*operator[^\(]+)(\(\s*\))(.*)/s ) {
    $pre = $1;
    $nested = " ";
    $rest = $3;
  } elsif( $desc =~ /([^\(]*)(\(.*)/s ) {
    $pre = $1;
    $rest = $2;
    GetNested( '\(','\)',\$rest, \$nested, 1 );
  }

  if( $nested ) {
    $sig = $nested;
    if( $pre =~ /(.*)\s+([\w:]+operator.*)$/s ) {
      $return = $1;
      $funcName = $2;
    } elsif( $pre =~ /(.*)\s+(operator.*)$/s ) {
      $return = $1;
      $funcName = $2;
    } elsif ( $pre =~ /(.*)\s+(~?[\w:]+)\s*$/s ) {
      $return = $1;
      $funcName = $2;
    } elsif ( $pre =~ /\s*(~?[\w:]+)\s*$/s ) {
      $return = "";
      $funcName = $1;
    } else {
      confess( "PARSE ERROR: func '$desc'" );
    }
  } else {
    confess( "PARSE ERROR: $info{ filename }:$PARSE_NR",
	     " func decl not found in\n",
	     $desc );
  }

  if( $rest =~ /^\s*const\s*=\s*0\s*;(.*)/s ) {
    $funcConst = "const";
    $funcPurVirtual = "= 0";
    $funcDesc = $1;
  } elsif( $rest =~ /^\s*const\s*=\s*0(.*)/s ) {
    $funcConst = "const";
    $funcPurVirtual = "= 0";
    $funcDesc = $1;
  } elsif ( $rest =~ /^\s*const\s*;(.*)/s ) {
    $funcConst = "const";
    $funcDesc = $1;
  } elsif ( $rest =~ /^\s*const(.*)/s ) {
    $funcConst = "const";
    $funcDesc = $1;
  } elsif( $rest =~ /^\s*;(.*)/s ) {
    $funcDesc = $1;
  } else {
    $funcDesc = $rest;
  }

  Debug( 2, "FUNCT VALUES: $funcName $sig\n
  type: '$funcType'
   ret: '$return'
  name: '$funcName'
  args: '$sig'
  cons: '$funcConst'
  virt: '$funcPurVirtual'
  desc: '$funcDesc'\n" );


  $sig =~ s/^\s+//;
  $sig =~ s/\s+$//;
  $sig =~ s/\s+/ /g;

  $funcName =~ s/^\s+//;
  $funcName =~ s/\s+$//;
  $funcName =~ s/\s+/ /g;

  if( length( $sig ) == 0 ) {
    $sig = "void";
  }

  if(  $return =~ /friend(.*)/ ) {
    $prot = "global";
    $return = $1;
  }

  if( $return =~ /template/ ) {
    my $tmplArgs;
    GetNested( '<','>',\$return, \$tmplArgs, 0 );
    $funcTmpl = "$tmplArgs";
  }

  if( $return =~ /(virtual|inline|static)\s*(.*)/ ) {
    $funcType = $1;
    $funcRet = $2;
  } else {
    $funcType = "";
    $funcRet = $return;
  }

  $funcType =~ s/^\s+//;
  $funcType =~ s/\s+$//;

  $funcRet =~ s/^\s+//;
  $funcRet =~ s/\s+$//;

  Debug( 2, "FOUND FUNCT: $funcName $sig\n
  tmpl: '$funcTmpl'
  type: '$funcType'
   ret: '$funcRet'
  name: '$funcName'
  args: '$sig'
  cons: '$funcConst'
  virt: '$funcPurVirtual'\n" );

  my $foundFunc = 0;
  my $funcList;

  if( $funcName !~ /::/ ) {
    if( $prot eq "global" ) {
      # Debug( 3, "GLOBAL FUNCLIST\n" );
      # DebugDumpHash(  5, "GLOBAL", $info , "down" );
      $funcList = $$info{ func };
    } else {
      $funcList
	= $$info{ "type"
		}->{ $$info{ MainClass }->{ number }
		   }->{ $$info{ MainClass }->{ "type" }
		      }->{ $$info{ MainClass }->{ name }
			 }->{ $prot }->{ func }; 
      Debug( 3, "MAIN CLASS FUNCLIST '$funcList'\n",
	     "MainClass: '$$info{ MainClass }->{ number }' ",
	     " '$$info{ MainClass }->{ type }' ",
	     " '$$info{ MainClass }->{ name }'\n"
	   );
    }
  } else {
    Debug( 3, "SUBCLASS FUNCLIST\n" );
    if( $funcName =~ /(.*)::(\w+|operator[^:]+)$/ ) {
      my $inClasses = $1;
      $funcName = $2;
      my $type = FindInnerClass( $info, $inClasses );
      DebugDumpHash( 2, "SUBTYPE:", $type, "down" );
      $funcList = $$type{ $prot }->{ func };
    } else {
      die "IMPOSIBLE ! ::";
    }
  }
  # DebugDumpHash( 2, "TEST:", $funcList , "down" );

  # Debug( 2, "DUMP COMPLETE\n" );

  foreach $fn (keys(  %$funcList )) {
    Debug( 2, "Checking '$funcName' == '$$funcList{ $fn }->{ name }'\n");
    if( $funcName eq $$funcList{ $fn }->{ name } ) {
      Debug( 2, "MATCH FUNCT: $fn $$funcList{ $fn }->{ name }",
	     "\n?? '$sig'\n== '$$funcList{ $fn }->{ args }'\n" );
      if( $sig eq $$funcList{ $fn }->{ args } ) {
	if( $funcConst eq $$funcList{ $fn }->{ const } ) {
	  $$funcList{ $fn }->{ desc } = $funcDesc;
	  $foundFunc = 1;
	  last;
	}
      }
    }
  }


  # DebugDumpHash(  3, "FUNCS", $info , "down" );
  if( ! $foundFunc ) {
    if( $prot eq "global" ) {

      # Go ahead and set Global even if not found. The
      # function was probably declared in an 'inlines' file.

      my $funcInfo = StoreFunc( "$funcTmpl $funcType $funcRet",
				$funcName,
				$sig,
				"$funcConst $funcPurVirtual",
				$info );
      $$funcInfo{ desc } = $funcDesc;
    } else {
      DebugDumpHash(  0, "FUNCS", $funcList , "down" );
      confess( "ERROR: $$info{ filename }:$PARSE_NR function",
	       " '$funcName( $sig ) $funcConst' not found.\n$desc" );
    }
  }
}

sub SetFieldDesc ($$$) {
  my $info	= shift( @_ );
  my $prot	= shift( @_ );
  my $desc	= shift( @_ );

  my $name;
  my $type;
  my $const;
  if( $decl = ~ /\s*static const\s+(\w.*)\s+(\w+)\s*;*\s*(.*)$/ ) {
    $section = "static_const";
    $type = $1;
    $name = $2;
    $desc = $3;
  } elsif ( $decl =~ /\s*(const)\s+(\w.*)\s+(\w+)\s*;*\s*(.*)$/ ) {
    $section = "variable";
    $type = $1;
    $name = $2;
    $desc = $3;
    $const = "const";
  } elsif ( $decl =~ /\s*(\w.*)\s+(\w+)\s*;*\s*(.*)$/ ) {
    $section = "variable";
    $type = $1;
    $name = $2;
    $desc = $3;
  } else {
    confess "FIELD DECL PARSE ERROR: '$decl'";
  }

  my $searchList;
  if( $name !~ /::/ ) {
    if( $prot eq "global" ) {
      $searchList = $$info{ $section };
    } else {
      $searchList
	= $$info{ "type"
		}->{ $$info{ MainClass }->{ number }
		   }->{ $$info{ MainClass }->{ "type" }
		      }->{ $$info{ MainClass }->{ name }
			 }->{ $prot }->{ $section };
    }
  } elsif ( $name =~ /(.*)::(\w+)$/ ) {
    my $inner = $1;
    my $name = $2;
    my $type = FindInnerClass( $info, $inner );
    $searchList = $$type{ $prot }->{ $section };
  } else {
    confess( "IMPOSIBLE ! ::" );
  }

  my $found = 0;
  foreach my $n (keys( %$searchList )) {
    if( $name eq $searchList{ $n }->{ name } ) {
      $searchList{ $n }->{ desc } = $desc;
      $found = 1;
      last;
    }
  }

  if( ! $found ) {
    confess( "ERROR: $$info{ filename }:$PARSE_NR field '$name' not found" );
  }
}



sub Parse ($$) {
  my $fn	    = shift( @_ );
  my $topHash  = shift( @_ );

  $$topHash{ filename } = $fn;
  $$topHash{ TopLevel } = 1;
  $$topHash{ define_num } = 1;
  $$topHash{ macro_num } = 1;

  open( IN, "< $fn" )
    || die "open '$fn' - $!";

  ParseHeaderInfo( \*IN, $topHash );

  my $comment = "";
  my $continue;
  my @containerStack;
  my $container = $topHash;
  my $context = "decl";
  my $trash;
  my $statement;
  my $line;

  while ( <IN> ) {
    Debug( 5, "SRC: $_" );

    $line = undef;

    if ( $continue ) {
      $value = $_;
      chop $value;
      if ( $value =~ /\\$/ ) {
	chop $value;
	$$continue .= " $value";
      } else {
	$$continue .= " $value";
	$continue = undef;
      }
      next;
    }

    if ( ! $inComment ) {
      if ( m@(.*)/\*(.*)@ ) {
	$line = "$1\n";
	$rest = "$2";
	if ( $rest =~ m@(.*)\*/(.*)@ ) {
	  $comment = "  $1";
	  $line = "$2\n";
	} else {
	  $inComment = 1;
	  $comment = "  $rest\n";
	}
      } elsif( m@((?<!//).*)//(.*)@ ) {
	$line = "$1\n";
	$comment = "  $1\n";
      } else {
	$line = $_;
      }
    } else {
      if ( m@(.*)\*/(.*)@ ) {
	$comment = "$1\n";
	$inComment = 0;
	$line = "$2\n";
	next;
      } else {
	if( /^(\s*)(\*+)(.*)$/ ) {
	  my $pre = $1;
	  my $stars = $2;
	  my $rest = $3;
	  my $starsLen = 0;
	  if( $stars ) {
	    $starsLen = length( $stars );
	  }
	  $comment = sprintf( "$pre%*s$rest\n", $starsLen, " " );
	} else {
	  $comment = $_;
	}
      }
    }

    if ( $comment && length( $comment ) ) {
      ParseComment( $comment, $topHash );
      $comment = "";
      if( ! $line ) {
	next;
      }
    }

    Debug( 5, "LINE: $line" );
    $_ = $line;

    if ( /\s*\#define\s+(\w+)\s+(.*)/ ) {
      my $defName = $1;
      my $defValue = $2;
      my $defNum = $$topHash{ define_num };
      ++ $$topHash{ define_num };
      $$topHash{ defines }->{ $defNum } = { name => $defName };

      if ( $defValue =~ /\\$/ ) {
	$trash = "";
	$$continue = \$trash;
      }
      Debug( 4, "DEFINE: $defName" );
      next;
    }

    if ( /\s*\#define\s+(\w+)\(([^\)]+)\)/ ) {
      my $macName = $1;
      my $macArgs = $2;
      my $macNum = $$topHash{ macro_num };
      Debug( 3, "MACRO: $macName" );
      ++ $$topHash{ macro_num };

      $$topHash{ macros }->{ $macNum } = { name => $macName,
					   args => $macArgs
					 };

      if ( /\\$/ ) {
	$trash = "";
	$$continue = \$trash;
      }
      DebugDumpHash( 4, "MACRO", $$topHash{ macros }, "down" );
      next;
    }

    # skip blank lines and other cpp directives
    if ( /^\s*$/ || /^\#/ ) {
      next;
    }

    chop;
    $statement .= " $_";
    Debug( 5, "STATEMENT: $statement" );

    if( $context eq $CNTX_CONSTRUCTOR_ARG_INIT ) {
      if( $statement =~ /([^\{]+)\{(.*)$/s ) {
	$statement = $2;
	$context = $CNTX_FUNC_BODY;
      } else {
	next;
      }
    }

    if ( $context eq $CNTX_FUNC_BODY ) {
      my $body;
      my $tmp = " \{ $statement";
      Debug( 5, "CNTX: funcbody '$tmp'" );
      if( GetNested( '{', '}', \$tmp, \$body, 0 ) ) {
	Debug( 5, "GOT BODY:",
	       ( $body ? "\n$body\n" : " ''" ) );
	$context = "decl";
	$statement = $tmp;
      } else {
	Debug( 5, "still looking.\n" );
	next;
      }
    }

    if ( $statement =~ /class[^\{]+:[^\{]+$/ ) {
      # hide the 'inheritance colon' until we get a open brace
      next;
    }

    $delim = "";

    if ( $statement =~ /^([^;\{\}\:]*)(:)([^:].*)$/ ) {
      $lead = $1;
      $delim = $2;
      $rest = $3;
    } elsif ( $statement =~ /^([^;\{\}\:]*)(:)$/ ) {
      $lead = $1;
      $delim = $2;
      $rest = "";
    } elsif ( $statement =~ /^([^;\{\}]*)([;\{\}])(.*)$/ ) {
      $lead = $1;
      $delim = $2;
      $rest = $3;
    }

    Debug( 5, "$NR ",
	   ($lead ? "'$lead'" : "''" ),
	   ", ",
	   ($delim ? "'$delim'" : "''"),
	   ", ",
	   ($rest ? '$rest' : "''" ),
	   "\n$statement" );

    if ( $delim ) {

      if ( $delim && $delim eq ":" && $lead =~ /class/ ) {
	if ( $statement =~ /^(.*class[^:]+:[^\{]+)(\{)(.*)$/ ) {
	  $lead = $1;
	  $delim = $2;
	  $rest = $3;
	  $container =  ParseOpenBrace( $lead, $container, \$context );
	  $statement = $rest;
	  next;
	}
      }
      if( $delim ) {
	if ( $delim eq "{" ) {
	  $container =  ParseOpenBrace( $lead, $container, \$context );
	} elsif ( $delim eq "}" ) {
	  $container =  ParseCloseBrace( $lead, $container, \$context );
	} elsif ( $delim eq ":" ) {
	  $container =  ParseLabel( $lead, $container, \$context );
	} elsif ( $delim eq ";" ) {
	  $container = ParseStatement( $lead, $container, \$context );
	}
      }
      $statement = $rest;
    }
  }

  while ( $statement && length( $statement ) ) {
    if ( $statement =~ /^([^;\{\}\:]*)([;\{\}\:])(.*)$/ ) {
      $lead = $1;
      $delim = $2;
      $rest = $3;

      if ( $delim eq "{" ) {
	$container =  ParseOpenBrace( $lead, $container, \$context );
      } elsif ( $delim eq "}" ) {
	$container =  ParseCloseBrace( $lead, $container, \$context );
      } elsif ( $delim eq ":" ) {
	$container =  ParseLabel( $lead, $container, \$context );
      } elsif ( $delim eq ";" ) {
	$container = ParseStatement( $lead, $container, \$context );
      }
      $statement = $rest;
    } else {
      last;
    }
  }

  Debug( 2, "PARSE COMPLETE HASH FOLLOWS" );
  DebugDumpHash( 2, "PARSE", $topHash, "down" );
  Debug( 2, "PARSE COMPLETE END  OF HASH" );
}

sub FindHash ($$) {
  my ($info, $name) = (@_);

  my $found = undef;

  Debug( 4, "FindHash '$info' '$name'" );
  DebugDumpHash( 4, "FindHash", $info, "down" );
  foreach my $num (keys(  %$info )) {
    Debug( 4, "  checking $num ", $$info{ $num }->{ name } );

    if( $name eq $$info{ $num }->{ name } ) {
      Debug( 4, "Found" );
      $found = $$info{ $num };
      last;
    }
  }
  return( $found );
}


sub ParseComment ($$) {
  my $comment = shift(@_);
  my $info  = shift(@_);

  my $prevSection = $commentSection;
  my $prevSectStartLineNumber = $commentSectionStartLineNum;

  $tabstop = 8;
  $comment = expand( $comment );
  Debug( 2, "COMMENT: $comment" );
  # print $comment;
  if ( $comment =~ m@^ {1,4}([A-Z]\w[^:]+):\s*(.*)@ ) {
    Debug( 1, "SECTION: $1 ($NR)\n" );
    $commentSection = $1;
    $text = $2;
    $commentSection =~ s/^\s+//;
    $commentSection =~ s/\s*$//;
    $commentSectionStartLineNum = $NR;
    $$info{ comments }->{ $commentSection } = "$text";
    # Debug( 5, "Found section: '$section'\n" );
  } else {
    if ( $commentSection && length( $commentSection ) ) {
      $text = $comment;
      $$info{ comments }->{ $commentSection } .= "$text";
    }
  }
  $comment = "";

  if ( $prevSection && length( $prevSection ) ) {
    if ( $prevSection ne $commentSection ) {
      Debug( 1, "NEW SECTION\n" );

      $PARSE_NR = $prevSectStartLineNumber - 1;
      my $text = $$info{ comments }->{ $prevSection };

      if ( $prevSection =~ /data types/i ) {
	
	# Data Types: section
	
	my $type;
	my $name;
	my $desc;
	foreach my $line (split(/\n/, $text)) {
	  ++ $PARSE_NR;
	  if ( $line
	       =~ /^\s+(class|struct|typedef|enum)\s+([\w:]+)\s*(.*)$/ ) {
	    my $tmpType = $1;
	    my $tmpName = $2;
	    my $tmpDesc = "$3\n";

	    SetTypeDesc( $info, "public", $type, $name, $desc );

	    $name = $tmpName;
	    $type = $tmpType;
	    $desc = $tmpDesc;
	  } elsif ( $line =~
		    /^\s*([\w:]+)\s+(class|struct|typedef|enum)\s*(.*)$/ ) {
	    my $tmpName = $1;
	    my $tmpType = $2;
	    my $tmpDesc = "$3\n";

	    SetTypeDesc( $info, "public", $type, $name, $desc );

	    $name = $tmpName;
	    $type = $tmpType;
	    $desc = $tmpDesc;
	  } else {
	    $desc .= "$line\n";
	  }
	}
	SetTypeDesc( $info, "public", $type, $name, $desc );

	
      } elsif ( $prevSection =~ /defines/i ) {

	# Defines: section

	my $defDesc;
	my $defName;
	foreach my $line (split(/\n/, $text)) {
	  ++ $PARSE_NR;

	  if ( $line =~ /^ {$tabstop}(\w+)\s*(.*)$/ ) {
	    my $name = $1;
	    my $desc = $2;
	    if( $defName && $defDesc ) {
	      my $defHash = FindHash( $$info{ defines }, $defName );
	      if( $defHash ) {
		$$defHash{ desc } = $defDesc;
		$defDesc = "";
	      } else {
		confess( "PARSE ERROR: define '$defName' UNKNOWN" );
	      }
	    }
	    $defName = $name;
	    $defDesc = $desc;
	  } elsif ( $line =~ /^( {9,}\S.*)$/ ) {
	    $defDesc .= "$1\n";
	  } elsif ( $line =~ /^\s*$/ ) {
	    $defDesc .= "$line\n";
	  } else {
	    confess( "PARSE ERROR: line:$PARSE_NR\n",
		     "   line: '$line'" );
	  }
	}
	
	if( $defName && $defDesc ) {
	  my $defHash = FindHash( $$info{ defines }, $defName );
	  if( $defHash ) {
	    $$defHash{ desc } = $defDesc;
	    $defDesc = "";
	  } else {
	    confess( "PARSE ERROR: define '$defName' UNKNOWN" );
	  }
	}
      } elsif ( $prevSection =~ /macros/i ) {

	# Macros: section

	my $macDesc;
	my $macArgs;
	my $macName;
	foreach my $line (split(/\n/, $text)) {
	  ++ $PARSE_NR;

	  if ( $line =~ /^ {$tabstop}(\w+)\((.*)\)\s*(.*)$/ ) {
	    my $name = $1;
	    my $args = $2;
	    my $desc = $3;
	    if( $macName && $macDesc ) {
	      my $macHash = FindHash( $$info{ macros }, $macName );
	      if( $macHash ) {
		$$macHash{ args } = $macArgs;
		$$macHash{ desc } = $macDesc;
	      } else {
		confess( "PARSE ERROR: define '$defName' UNKNOWN" );
	      }
	    }
	    $macName = $name;
	    $macArgs = $args;
	    $macDesc = $desc;
	  } elsif ( $line =~ /^( {9,}\S.*)$/ ) {
	    $macDesc .= "$1\n";
	  } elsif ( $line =~ /^\s*$/ ) {
	    $macDesc .= "$line\n";
	  } else {
	    confess( "PARSE ERROR: line:$PARSE_NR\n",
		     "   line: '$line'" );
	  }
	}
	
	if( $macName && $macDesc ) {
	  my $macHash = FindHash( $$info{ macros }, $macName );
	  if( $macHash ) {
	    $$macHash{ args } = $macArgs;
	    $$macHash{ desc } = $macDesc;
	  } else {
	    confess( "PARSE ERROR: define '$defName' UNKNOWN" );
	  }
	}
      } elsif ( $prevSection =~ /public interface/i
		|| $prevSection =~ /constructors/i
		|| $prevSection =~ /destructors/i
		|| $prevSection =~ /accociated functions/i
		|| $prevSection =~ /functions/i ) {
	my $text = $$info{ comments }->{ $prevSection };
	my $sectProt = "public";
	if ( $prevSection =~ /protected interface/i ) {
	  $sectProt = "protected";
	} elsif ( $prevSection =~ /accociated functions/i
		  || $prevSection =~ /functions/i ) {
	  $sectProt = "global";
	}
	Debug( 3, "$prevSection:\n$text\n" );
	DebugDumpHash(  3, "DESC", $info , "down" );

	# $tabstop = 7;
	# my @origLines = split( /\n/,$text );
	# my @detabLines = expand( @origLines );
	# $text = join( /\n/,@detabLines );
	# $text = expand( $text );
	# $text =~ s/ +\n/\n/g;
	# Debug( 1, "EXPANDED:\n$text\n" );

	#my $funcDecl;
	#my $funcDesc;
	#my $context;

	my $itemDesc;
	my $haveSomeDesc = 0;
	my $isFuncDecl;
	my $wasFuncDecl;

	foreach $line (split(/\n/,$text)) {
	  ++ $PARSE_NR;
	  Debug( 3, "LINE: '$line'\n" );

	  if ( $line =~ /^( {$tabstop}\S.*)$/ ) {

	    my $tmp = "$1\n";

	    $wasFuncDecl = $isFuncDecl;

	    if ( $tmp =~ /\(/ ) {
	      Debug( 4, "FOUND OPEN PAREN" );
	      $isFuncDecl = 1;
	    }

	    if ( $haveSomeDesc ) {

	      Debug( 4, "DESC: is funct: $wasFuncDecl\n",
		     "$itemDesc" );
		
	      if ( $wasFuncDecl ) {
		SetFuncDesc( $info, $sectProt, $itemDesc );
	      } else {
		SetFieldDesc( $info, $sectProt, $itemDesc );
	      }

	      $itemDesc = "";
	      $haveSomeDesc = 0;
	      $isFuncDecl = 0;
	    }
	    $itemDesc .= "$tmp";

	  } elsif ( $line =~ /^( {9,}\S.*)$/ ) {

	    # item desc continuation lines
	    $itemDesc .= "$line\n";
	    $haveSomeDesc = 1;
	  } elsif ( $line =~ /^\s*$/ ) {

	    # blank line
	    if ( $itemDesc ) {
	      $itemDesc .= "$line\n";
	      $haveSomeDesc = 1;
	    }
	  } else {
	    confess( "PARSE ERROR: line:$PARSE_NR\n",
		     "   line: '$line'" );
	  }
	}
	if ( $itemDesc && $haveSomeDesc ) {
	
	  Debug( 4, "DESC: is funct: $wasFuncDecl\n",
		 "$itemDesc" );
		
	  if ( $isFuncDecl ) {
	    SetFuncDesc( $info, $sectProt, $itemDesc );
	  } else {
	    SetFieldDesc( $info, $sectProt, $itemDesc );
	  }
	}

      } elsif( $prevSection =~ /example/i ) {
	$$info{ example } = $text;
      } else {
	Debug( 0, "UNPROCESSED SECTION: $prevSection\n" );
      }
    } else {
      # Debug( 1, "SAME SECTION: $prevSection\n" );
    }
  }
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

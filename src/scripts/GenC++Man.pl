#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            GenMan.pl
# 
# Description:
# 
#   Generate a man page from a C++ header file that
#   Contains correctly formated comments.
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    04/17/96 10:59
# 
# Revision History: (See end of file for Revision Log)
#
# $Id$

@SectionOrder = ("TITLE",
		 "NAME",
		 "SYNOPSIS",
		 "DESCRIPTION",
		 "CONSTANTS",
		 "MACROS",
		 "FUNCTIONS",
		 "CONSTRUCTORS",
		 "PUBLIC INTERFACE",
		 "ASSOCIATED MACROS",
		 "ASSOCIATED FUNCTIONS",
		 "EXAMPLE",
		 "SEE ALSO",
		 "FILES",
		 "AUTHOR" );

		 
$DEBUG = 1;	 
		 
sub FormatMethText
  {
    my $desc = pop( @_ );
    my $const = pop( @_ );
    my $args = pop( @_ );
    my $name = pop( @_ );
    my $ret = pop( @_ );
    my $type = pop( @_ );

    my $text;

    if( $DEBUG )
      {
	print STDERR "name: $name\n";
	print STDERR "type: $type\n";
	print STDERR "ret: $ret\n";
	print STDERR "args: $args\n";
	print STDERR "const: $const\n\n";
      }

    $text = ".PD 0\n";
    
    if( $type )
      {
	$text .= "$type\n.PP\n";
      }
    if( $ret )
      {
	$text .= "$ret\n.PP\n";
      }
    
    if( $name )
      {
	$text .= "$name(";

	if( length( $args ) < 50 )
	  {
	    if( ! $args )
	      {
		$args = "";
	      }
	    $text .= "$args) $methConst\n";
	  }
	else
	  {
	    $text .= "\n.RS 2\n";
	    
	    my $argOut = "";
	
	    foreach $a (split(/,/,$args))
	      {
		$argType = "";
		$argName = "";
		if( $a =~ /=/ )
		  {
		    $a =~ /^[ \t]*(.*)[ \t]([A-Za-z_]+ += .+)[ \t]*$/;
		    $argType = $1;
		    $argName = $2;
		  }
		else
		  {
		    $a =~ /^[ \t]*(.*)[ \t]([A-Za-z_]+)[ \t]*$/;
		    $argType = $1;
		    $argName = $2;
		  }
		$argName =~ s/\\/\\\\/g;
		$argOut .= ".TP 25\n$argType\n$argName,\n";
	      }
	    chop $argOut;
	    chop $argOut;
	    
	    $text .= "$argOut ) $methConst\n.RE\n";
	  }
      }
    $text .= ".PD\n.PP\n.RS\n";    
    $text .= "$desc\n";
    $text .= ".RE\n.PP\n";

    $text;
  }
  
$SourceFile = $ARGV[0];
$LibName = $ARGV[1];

if( ! $ARGV[1] )
{
  $PrjName = "Clue";
}

if( open( HDR, "<$SourceFile" ) != 1 )
{
  die( "Can't open: $SourceFile" );
}

while(<HDR>)
{
  if( ! /^\/\// )
    {
      next;
    }

  if( /(\$ *Id: *[^\$]+\$)/ )
     {
#       print STDERR "$1\n";
       $VersionTag = $1;
     }
     
  if( /^\/\/ +([A-Z][A-Za-z ]+[A-Za-z]):[ \t]*(.*)/ )
    {
      $sect = $1;
      $SectionText{ $sect} = $2;
      next;
    }

  if( $sect &&
     $sect ne "File" &&
     $sect ne "Revision History" &&
     $sect ne "Created" )
    {
#      print "$sect $_";
      $SectionText{ $sect } .= $_;
    }
  
}

$ClassName = "/$SourceFile";
$ClassName =~ s@.*/([^/]+)\.hh@\1@;

if( $SectionText{ "Project" } )
  {
    $PrjName = $SectionText{ "Project" };
    $PrjName =~  s/^\/\///mg;
    $PrjName =~  s/^[ \t]*//;
    $PrjName =~  s/[ \t]*$//;
  }

if( $VersionTag =~ /(\d\d\d\d)\/(\d\d*)\/(\d\d*)/ )
{
  $Date = "$2/$3/$1";
}

$Man{ "TITLE" } = ".TH $ClassName 3 \"\" \"$Date\" \"$PrjName\"\n";
$Man{ "NAME" } = ".SH NAME\n$ClassName\n";

if( $VersionTag )
{
  $Man{ "NAME" } .= ".PP\n$VersionTag\n.PD\n";
}

$Man{ "SYNOPSIS" } = ".SH SYNOPSIS\n";
$Man{ "SYNOPSIS" } .= "#include <$ClassName.hh>\n";
$Man{ "SYNOPSIS" } .= ".PP\n";
if( $SectionText{ "Public Interface" } )
{
  $Man{ "SYNOPSIS" } .= "$ClassName  obj;\n";
}
$Man{ "DESCRIPTION" } = ".SH DESCRIPTION\n";

$SectionText{ "Desc" } =~ s/\/\/ *//g;
$SectionText{ "Desc" } =~ s/\\/\\\\/g;
$SectionText{ "Desc" } =~ s/^[ \t]*\n//;
$SectionText{ "Desc" } =~ s/[\t ]*\n[ \t]*\n/.PP/mg;
$SectionText{ "Desc" } =~ s/[\n\t ]*$//;
$SectionText{ "Desc" } =~ s/[ \t]+/ /g;
$SectionText{ "Desc" } =~ s/\n//g;
$SectionText{ "Desc" } =~ s/\.PP/\n.PP\n/g;
$SectionText{ "Desc" } =~ s/^[ \t]+//mg;



$Man{ "DESCRIPTION" } .= $SectionText{ "Desc" } . "\n";

if( $SectionText{ "Constants" } )
{
  $SectionText{ "Constants" } =~ s/^\/\///mg;
  
  $Man{ "CONSTANTS" } = ".SH CONSTANTS\n";
  $Man{ "CONSTANTS" } .= ".PD 0\n";

  $constName = "";
  $constDesc = "";
  
  foreach $ln (split( /\n/, $SectionText{ "Constants" } ) )
    {
      if( $ln =~ /^ {0,5}[ \t]([A-Z_]+)/ )
	{
	  if( $constName )
	    {
	      $Man{ "CONSTANTS" } .= "$constName\n";
	      $Man{ "CONSTANTS" } .= ".PD\n.PP\n.RS\n";
	      $Man{ "CONSTANTS" } .= "$constDesc\n";
	      $Man{ "CONSTANTS" } .= ".RE\n.PP\n";
	    }
	  $constName = $1;
	  $constDesc = "";
	}
      else
	{
	  $ln =~ s/^[ \t]*//;
	  $ln =~ s/[ \t]+/ /g;
	  $constDesc .= $ln;
	}
    }
  
  if( $constName )
    {
      $Man{ "CONSTANTS" } .= "$constName\n";
      $Man{ "CONSTANTS" } .= ".PD\n.PP\n.RS\n";
      $Man{ "CONSTANTS" } .= "$constDesc\n";
      $Man{ "CONSTANTS" } .= ".RE\n.PP\n";
    }
}

if( $SectionText{ "Constructors" } )
{
  $Man{ "CONSTRUCTORS" } = ".SH CONSTRUCTORS\n";

  $SectionText{ "Constructors" } =~ s/^\/\///mg;

  # print $SectionText{ "Constructors" } . "\n";
  
  foreach $ln (split(/\n/,$SectionText{ "Constructors" }))
    {
      if( $ln =~ /^ {0,5}[ \t]([A-Za-z_]+)[ \t]*\(([^\)]+)(\)*)/ )
	{
	  if( $meth )
	    {
	      #	  print "$methArgs\n";
	      $Man{ "CONSTRUCTORS" } .=
		FormatMethText( "",$meth,$methArgs,"",$methDesc);
	    }
	  $meth = $1;
	  $methArgs = $2;
	  $allArgs = $3;
	  $methDesc = "";
	  
	  next;
	}
  
      if( ! $allArgs )
	{
	  if( $ln =~ /^[ \t]+([^\)]+)(\)*)/ )
	    {
	      $methArgs .= $1;
	      $allArgs = $2;
	    }
	}
      else
	{
	  $ln =~ s/^[ \t]*//;
	  $ln =~ s/[ \t]+/ /g;
	  $methDesc .= "$ln ";
	}
    }
}

$Man{ "CONSTRUCTORS" } .= FormatMethText( "","",$meth,$methArgs,"",$methDesc);

$meth = "";

   
foreach $sect ("Macros",
	       "Public Interface",
	       "Protected Interaface",
	       "Private Interface",
	       "Associated Macros",
	       "Associated Functions",
	       "Functions" )
{
  $SectionText{ $sect } =~ s/^\/\///mg;
  
  if( $SectionText{ $sect } =~ /[^ \t\n]/ )
    {
      $Section = $sect;
      $Section =~ tr/a-z/A-Z/;
     
      $Man{ $Section } = ".SH $Section\n";
    }

  foreach $ln (split(/\n/,$SectionText{ $sect }))
    {
      # look for method type
      if( $ln =~ /^ {0,5}[ \t]((inline)|(virtual)|(static)|(template.*))\s*$/ )
	{
	  if( $meth )
	    {
	      $Man{ $Section } .= FormatMethText( $methType,
						 $methRet,
						 $meth,
						 $methArgs,
						 $methConst,
						 $methDesc);
	      $methRet = "";
	      $meth = "";
	      $methConst = "";
	      $methDesc = "";
	    }
	  $methType = $1;
	  next;
	}

      # look for return type
      if( $ln =~ /^ {0,5}[ \t]([^ \t][^(]*)$/ )
        {
	  if( $meth )
	    {
	      $Man{ $Section } .= FormatMethText( $methType,
						$methRet,
						$meth,
						$methArgs,
						$methConst,
						$methDesc );
	      $methType = "";
	      $meth = "";
	      $methConst = "";
	      $methDesc = "";
	    }
	  $methRet = $1;
	  next;
	}

  # look for method and args
      if( $ln =~ /^ {0,5}[ \t]([^ \t][^\(]+)[ \t]*\(([^\)]*)(\)*)[ \t]*([const]*)/ )
	{
	  if( $meth )
	    {
	      $Man{ $Section } .= FormatMethText( $methType,
						 $methRet,
						 $meth,
						 $methArgs,
						 $methConst,
						 $methDesc );
	      $methRet = "";
	      $methType = "";
	      $methDesc = "";
	    }
	  $meth = $1;
	  $methArgs = $2;
	  $allArgs = $3;
	  $methConst = $4;
	  $methDesc = "";
	  
	  next;
	}
      
      if( ! $allArgs )
	{
	  if( $ln =~ /^[ \t]+([^\)]+)(\)*)[ \t]*([const]*)/ )
	    {
	      $methArgs .= $1;
	      $allArgs = $2;
	      $methConst = $3;
	    }
	  next;
	}
      
      $ln =~ s/^[ \t]*//;
      $ln =~ s/[ \t]+/ /g;
      $ln =~ s/\\/\\\\/g;
      $methDesc .= "$ln ";
      
    }
  
  if( $methRet || $meth )
    {
      $Man{ $Section } .= FormatMethText( $methType,
					 $methRet,
					 $meth,
					 $methArgs,
					 $methConst,
					 $methDesc);
      $methType = "";
      $methRet = "";
      $meth = "";
      $methArgs = "";
      $methConst = "";
      $methDesc = "";
    }
}

$SectionText{ "Example" } =~ s/^\/\///mg;

if( $SectionText{ "Example" } )
{
  $Man{ "EXAMPLE" } = ".SH EXAMPLE\n";
  $Man{ "EXAMPLE" } .= ".nf\n";
  foreach $ln (split(/\n/,$SectionText{ "Example" }))
    {
      $ln =~ s/^\t//;
      $Man{ "EXAMPLE" } .= "$ln \n";
    }
  #      print $SectionText{ "Example" };
  $Man{ "EXAMPLE" } .= ".fn\n";
}

$SectionText{ "See Also" } =~ s/^\/\///mg;
$SectionText{ "See Also" } =~ s/^[ \t]*//;
$SectionText{ "See Also" } =~ s/[ \t]+/ /g;

if( $SectionText{ "See Also" } )
{
  $Man{ "SEE ALSO" } = ".SH SEE ALSO";
  $Man{ "SEE ALSO" } .= $SectionText{ "See Also" };
  $Man{ "SEE ALSO" } .= "\n";
}

$SectionText{ "Files" } =~ s/^\/\///mg;
$SectionText{ "Files" } =~ s/^[ \t]*//;
$SectionText{ "Files" } =~ s/[ \t]+/ /g;

if( $SectionText{ "Files" } )
{
  $Man{ "FILES" } = ".SH FILES";
  $Man{ "FILES" } .= $SectionText{ "Files" };
  $Man{ "FILES" } .= "\n";
}

$SectionText{ "Author" } =~ s/^ \t//;
$Man{ "AUTHOR" } = ".SH AUTHOR\n";
$Man{ "AUTHOR" } .= $SectionText{ "Author" } . "\n";
  
foreach $sect (@SectionOrder)
  {
    if( $Man{ $sect } )
      {
	print $Man{ $sect };
      }
  }
    
  
#
# Revision Log:
#
# $Log$
# Revision 1.3  1996/11/14 23:15:32  houghton
# Complete Rework.
#
# Revision 1.2  1996/10/26 10:34:45  houghton
# on-going development and improvements.
#
# Revision 1.1  1996/10/02 12:07:42  houghton
# *** empty log message ***
#
# 

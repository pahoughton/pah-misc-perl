#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            GenMan.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    04/17/96 10:59
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1996/10/02 12:07:42  houghton
# *** empty log message ***
#
# 

sub PrintMeth
  {
    my $desc = pop( @_ );
    my $const = pop( @_ );
    my $args = pop( @_ );
    my $name = pop( @_ );
    my $ret = pop( @_ );
    my $type = pop( @_ );

    print ".PD 0\n";
    
    if( $type )
      {
	print "$type\n.PP\n";
      }
    if( $ret )
      {
	print "$ret\n.PP\n";
      }
    
    if( $name )
      {
	print "$name( ";
      }

    if( length( $args ) < 40 )
      {
	if( ! $args )
	  {
	    $args = "void";
	  }
	print "$args ) $methConst\n";
      }
    else
      {
	print "\n.RS 2\n";

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
	    $argOut .= ".TP 20\n$argType\n$argName,\n";
	  }
	chop $argOut;
	chop $argOut;

	print "$argOut ) $methConst\n.RE\n";
      }
    print ".PD\n.PP\n.RS\n$desc\n.RE\n.PP\n";
  }
  
$SourceFile = $ARGV[0];
$LibName = $ARGV[1];

if( ! $ARGV[1] )
{
  $LibName = "Clue";
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

print ".TH $ClassName 3 $LibName\n";
print ".SH NAME\n$ClassName\n";

print ".SH DESCRIPTION\n";

$SectionText{ "Desc" } =~ s/\/\/ *//g;
$SectionText{ "Desc" } =~ s/^\n//;
$SectionText{ "Desc" } =~ s/[\t ]*\n[ \t]*\n/\n.PP\n/;
$SectionText{ "Desc" } =~ s/[\n\t ]*$//;

print $SectionText{ "Desc" } . "\n";

print ".SH Constructors\n";

$SectionText{ "Constructors" } =~ s/^\/\///mg;

# print $SectionText{ "Constructors" } . "\n";
  
foreach $ln (split(/\n/,$SectionText{ "Constructors" }))
{
  if( $ln =~ /^ {0,5}[ \t]([A-Za-z_]+)[ \t]*\(([^\)]+)(\)*)/ )
    {
      if( $meth )
	{
#	  print "$methArgs\n";
	  &PrintMeth( "",$meth,$methArgs,"",$methDesc);
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
      $methDesc .= "$ln ";
    }
}

&PrintMeth( "","",$meth,$methArgs,"",$methDesc);
$meth = "";

print ".SH Public Interface\n";

$SectionText{ "Public Interface" } =~ s/^\/\///mg;

foreach $ln (split(/\n/,$SectionText{ "Public Interface" }))
{
  if( $ln =~ /^ {0,5}[ \t]((inline)|(virtual)|(static))\s*$/ )
     {
       if( $meth )
	 {
	   &PrintMeth( $methType,$methRet,$meth,$methArgs,$methConst,$methDesc);
	   $methRet = "";
	   $meth = "";
	   $methConst = "";
	 }
       $methType = $1;
       next;
     }
       
  if( $ln =~ /^ {0,5}[ \t]([^ \t][^(]+)$/ )
    {
      if( $meth )
	{
	  &PrintMeth( $methType,$methRet,$meth,$methArgs,$methConst,$methDesc);
	  $methType = "";
	  $meth = "";
	  $methConst = "";
	}
      $methRet = $1;
      next;
    }
      
  if( $ln =~ /^ {0,5}[ \t]([^ \t][^\(]+)[ \t]*\(([^\)]+)(\)*)[ \t]*([const]*)/ )
    {
      if( $meth )
	{
	  &PrintMeth( $methType,$methRet,$meth,$methArgs,$methConst,$methDesc);
	  $methRet = "";
	  $methType = "";
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
    }
  else
    {
      $ln =~ s/^[ \t]*//;
      $methDesc .= "$ln ";
    }
}

  &PrintMeth( $methType,$methRet,$meth,$methArgs,$methConst,$methDesc);

  print ".SH AUTHOR\n";

  $SectionText{ "Author" } =~ s/^ \t//;
  print $SectionText{ "Author" } . "\n";
  

  

#!/usr/bin/perl
#
# Title:        df.pl
# Project:	System
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	03/04/98 07:11
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author: $
#   Last Mod:	    $Date: $
#   Version:	    $Revision: $
#
#   $Id: $
# 

sub CommaNum {
  my $num = pop( @_ );
  my $commanum = "";
  
#  print "'$num'\n";
  while( $num )
    {
      if( length( $num ) > 3 )
	{
	  $end = substr( $num, -3, 3 );
	  $num = substr( $num, 0, -3 );
	  if( $commanum )
	    {
	      $commanum = "$end,$commanum";
	    }
	  else
	    {
	      $commanum = "$end";
	    }
	}
      else
	{
	  if( $commanum )
	    {
	      $commanum = "$num,$commanum";
	    }
	  else
	    {
	      $commanum = "$num";
	    }
	  last;
	}
    }

  $commanum;
}

open( DUOUT, "/usr/bin/du -k @ARGV |" );

print "          Size     Name\n";

while( <DUOUT> ) {

  if( /^\s*(\d+)\s*(\S+)/ ) {
    $size = $1;
    $name = $2;

    printf( "%12s  $name\n",CommaNum( $size ) );
  }
}

#
# $Log: $
#

# Local Variables:
# mode:perl
# End:


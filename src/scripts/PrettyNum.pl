#!/usr/bin/perl
#
# Title:        PrettyNum.pl
# Project:	PerlLib
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	05/02/99 11:41
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

sub PrettyNum
  {
  my $num = pop( @_ );
  my $commanum = "";
  
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
    
1;


#
# $Log$
# Revision 2.1  1999/05/03 14:28:41  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

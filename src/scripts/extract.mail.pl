#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            extract.mail.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    12/03/96 09:53
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1997/02/24 15:26:24  houghton
# Initial Version.
#
# 



while(<>)
{
  if( /^begin \d\d\d (.*)$/ )
    {
      $file = 1;
      $name = $1;
      $fileData = "";
      print "Found: $name\n";
    }

  if( /^end/ )
    {
      if( $file )
	{
	  $fileData .= $_;
	  open( OUT, ">/tmp/extract.$name" );
	  print OUT $fileData;
	  close( OUT );
	  print "Decodeing: $name\n";
	  system( "uudecode < /tmp/extract.$name" );
#	  unlink( "/tmp/extract.tmp" );
	  $file = 0;
	}
    }

  if( $file )
    {
      $fileData .= $_;
    }
}
	    

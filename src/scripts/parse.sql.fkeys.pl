#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            parse.sql.fkeys.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    5/8/94
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 14:58:12  houghton
# Initial Version.
#
# 

$keydef = 0;

while(<>)
{
  if(/sp_foreignkey\s\s*(\w*)[\s,]*(\w*)[\s,]/)
    {
      print "sp_dropkey foreign, $1,$2\ngo\n";
      $keydef = 1;
    }
  if($keydef == 1)
    {
      print $_;
      if(/^go/)
	{
	  $keydef = 0;
	}
    }
}

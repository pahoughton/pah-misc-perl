#!/usr/local/bin/perl
#
# Title:        fixbcc.pl
# Project:	Mail
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	05/12/99 05:59
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

$more = 0;

while( <> )
  {
    if( /^Subject:/ )
      {
	print;
	++ $more;
	last;
      }

    if( /Blind-Carbon-Copy:/ )
      {
	print;
	++ $more;
	last;
      }
    
    if( ! /^\s$/ )
      {
	print;
      }
	
  }

if( $more ) { while( <> ) { print; } }

#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

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
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

use lib "$ENV{HOME}/scripts/perllib";

require "PrettyNum.pl";

foreach $pdir (split(/:/,$ENV{PATH}))
  {
    if( -x "$pdir/df"
        && "$pdir/df" ne $0 )
      {
	$real_df = "$pdir/df";
	last;
      }
  }

if( ! $real_df )
  {
    die "did NOT find real 'df' in $ENV{PATH}\n";
  }

open( DFOUT, "$real_df -k @ARGV |" );

print "          Size          Used             Avail  (all values in KB)\n";

while( <DFOUT> )
  {
    
    if( /^\S*\s+(\d+)\s+(\d+)\s+(\d+)\s+\d+%\s+(\S+)/ )
      {
	$total = PrettyNum( $1 );
	$used = PrettyNum( $2 );
	$avail = PrettyNum( $3 );
	$percent = $2 * 100 / $1;
        printf ("  %12s  %12s %2d%%  %12s  $4\n",
                $total, $used, $percent, $avail, );
      }
  }

#
# $Log$
# Revision 1.3  1999/10/14 11:08:21  houghton
# Added percent used to output.
#
# Revision 1.2  1999/05/04 11:42:08  houghton
# Bug-Fix: was not passing args to real df prog.
#
# Revision 1.1  1999/05/03 14:28:38  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:


#
# File:		dt.pl
# Project:	Data 
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton 719-527-7834 paul.houghton@mci.com
# Created:     07/08/2003 17:32
#
# Revision Info: (See ChangeLog or cvs log for revision history)
#
#	$Author: $
#	$Date: $
#	$Name:$
#	$Revision: $
#	$State: $
#
# $Id: $
#



eval 'exec perl -W $0 ${1+"$@"}'
    if 0 ;
use strict;
use warnings;

package dt;

my $total = 0;

while( <> ) {
  if( /:\s+(\d+)/ ) {
    $total += $1;
  }
}


print "Total: $total\n";

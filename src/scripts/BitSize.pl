#
# File:		BitSize.pl
# Project:	Tlu 
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton 719-527-7834 paul.houghton@mci.com
# Created:     08/23/2005 17:52
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

package BitSize;


my $size=0;

while( <> ) {
  if( /:\s*(\d+)\s*;/ ) {
    $size += $1;
    chop;
    printf( "$_ /*  tb: %4d w: %02d b: %02d\n", $size, $size / 16, $size % 16 );
  } elsif (/\}/) {
    chop;
    print $_," ",($size / 2),"\n";
    $size = 0;
  }
}

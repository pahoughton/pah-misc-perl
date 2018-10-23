#!/Tools/bin/perl
#
# Title:        linelen.pl
# Project:	Ncm
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	07/19/99 06:34
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author: $
#   Last Mod:	    $Date: $
#   Version:	    $Revision: $
#
#   $Id: $
# 


while( <> )
  {
    $len = length;
    $ll{$len} += 1;
  }

foreach $l (sort(keys(%ll)))
  {
    print "$l $ll{$l}\n";
  }



#
# $Log: $
#

# Local Variables:
# mode:perl
# End:

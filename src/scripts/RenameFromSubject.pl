#!/usr/local/bin/perl
#
# Title:        RenameFromSubject.pl
# Project:	Cooking
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	04/21/02 06:34
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 


foreach my $fn (@ARGV) {
  open( IN, "< $fn" ) || die "open $fn - $!";
  while( <IN> ) {
    s/\r//;
    if( /^Subject: (.*)/ ) {
      my $sn = "$1.txt";
      $sn =~ s/\"//;
      print "$fn - $sn\n";
      rename( $fn, $sn );
      last;
    }
  }
}


#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

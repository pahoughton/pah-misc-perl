#!/Tools/bin/perl
#
# Title:        checkplus.pl
# Project:	Ncm
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	07/19/99 06:58
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author: $
#   Last Mod:	    $Date: $
#   Version:	    $Revision: $
#
#   $Id: $
# 

$pos = 519;
  
while( <> )
  {
    $c = substr( $_, $pos, 1 );
    
    if( $c ne ',' )
      {
	print "char at $pos is '$c'\n";
	die;
      }
    $n = substr( $_, $pos + 1, 1 );

    if( $n eq ',' )
      {
	print "char at $pos is '$c'\n";
	die;
      }
	
  }



#
# $Log: $
#

# Local Variables:
# mode:perl
# End:

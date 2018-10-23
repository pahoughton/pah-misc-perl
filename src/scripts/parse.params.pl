#
# File:		parse.params.pl
# Project:	Trs 
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton 719-527-7834 paul.houghton@mci.com
# Created:     07/23/2003 15:02
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

package parse_params;

our %parm;
while( <> ) {
  s/[^&]+(&[A-Z0-9]+)/$1 /g;
  foreach my $p (split(/\s+/)) {
    $parm{ $p } = 1;
  }
}
foreach my $p (sort(keys(%parm))) {
  print $p,"\n";
}

# &CCTR
# &CTLPRFX
# &CTR
# &FEED
# &GEN
# &JOBNAME
# &OCTR
# &OSYS
# &RGEN
# &RSYS

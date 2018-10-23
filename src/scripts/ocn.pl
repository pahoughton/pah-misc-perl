#
# File:		ocn.pl
# Project:	Tlu 
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton 719-527-7834 paul.houghton@mci.com
# Created:     09/26/2005 18:59
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

package ocn;

open( LERG_ONE, "/lookups/inbound/tlu/refdata/tra/lerg1.dat" );

our %LergOne;
while( <LERG_ONE> ) {
  my $ocn;
  $ocn = substr( $_, 0, 4 );
  $LergOne{ $ocn } = substr( $_, 4, 20 );
  $LergOne{ $ocn } =~ s/,/ /g;
  # print "$ocn\n";
}

close( LERG_ONE );

open( OLD,  "q8.old.dat" );

our ($tn, $lrn, $eo, $rgn, $lata, $ocn, $net, $jkey );
our %Data;
while( <OLD> ) {
  chop;
  $tn = substr( $_, 0, 10 );
  $lrn = substr( $_, 11, 10 );
  $eo = substr( $_, 22, 11 );
  $rgn = substr( $_, 34, 2 );
  $lata = substr( $_, 39, 3 );
  $ocn = substr( $_, 44, 4 );
  $net = substr( $_, 49, 3 );
  $jkey = $tn;
  $jkey .= substr( $_, 58, 6 );
  $jkey .= substr( $_, 81 );
  $jkey =~ s/  *$//;

  $Data{ $jkey } =
    join(',', ($tn, $lrn, $eo, $rgn, $lata, $ocn, $net ) );

  # print "OLD: $jkey\n";
  # print join(',', ($tn, $lrn, $eo, $rgn, $lata, $ocn, $net, $jkey )),"\n";
}

open( NEW,  "q8.new.dat" );
while( <NEW> ) {
  chop;
  $tn = substr( $_, 0, 10 );
  $lrn = substr( $_, 11, 10 );
  $eo = substr( $_, 22, 11 );
  $rgn = substr( $_, 34, 2 );
  $lata = substr( $_, 39, 3 );
  $ocn = substr( $_, 44, 4 );
  $net = substr( $_, 49, 3 );
  $jkey = $tn;
  $jkey .= substr( $_, 58, 6 );
  $jkey .= substr( $_, 81 );
  $jkey =~ s/  *$//;
  
  my $old;
  $old = $Data{ $jkey };
  # print $jkey,$old,"\n";
  if( $old ) {
    my ($otn, $olrn, $oeo, $orgn, $olata, $oocn, $onet, $ojkey )
      = split( ',',$old );

    if( $eo eq $oeo ) {
      print ",SAME,",
	join( ',', ($net, $tn, $lrn, $eo, $oeo, $rgn, $lata, $ocn, $oocn,
		    $LergOne{ $ocn }, $LergOne{ $oocn } ) ),"\n";
    } else {
      print ",DIFF,",
	join( ',', ($net, $tn, $lrn, $eo, $oeo, $rgn, $lata, $ocn, $oocn,
		    $LergOne{ $ocn }, $LergOne{ $oocn } ) ),"\n";
    }
  }
}
  


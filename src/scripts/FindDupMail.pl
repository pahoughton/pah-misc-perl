#!/usr/local/bin/perl
#
# Title:        FindDupMail.pl
# Project:	Mail
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	04/14/03 16:10
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

use strict;

package FindDupMail;

use File::Find;
use IO::File;

my %MsgId;

sub wanted {

  my $fn = $File::Find::name;

  if( /\d+/ && -f $fn ) {
    my $hold = $_;
    my $in = new IO::File( "< $fn" );
    defined( $in ) || die "open '$fn' - $!";
    while( <$in> ) {
      if( /Message-id: (.*)/ ) {
	my $msgId = $1;
	push( @{$MsgId{ $msgId }}, $fn );
	last;
      }
    }
    $in->close();
    $_ = $hold;
  }
}

find( \&wanted, '/home/houghton/Mail/MH' );
      
foreach my $mid (keys( %MsgId )) {
  if( scalar( @{$MsgId{ $mid }} ) > 1 ) {
    print "$mid\n";
    foreach my $fn (@{$MsgId{ $mid }}) {
      print "    $fn\n";
      my $in = new IO::File( "< $fn" );
      while( <$in> ) {
	if( /Subject: (.*)/ ) {
	  my $sub = $1;
	  print "        $sub\n";
	  last
	}
      }
      $in->close();
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

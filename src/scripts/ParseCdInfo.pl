#!/usr/local/bin/perl
#
# Title:        ParseCdInfo.pl
# Project:	Music
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	04/13/03 02:05
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

sub dump_cd_info {
  my ($cd_info) = (@_);

  my $cd_id = $$cd_info{ id };
  my $cd_artist = $$cd_info{ artist };
  my $cd_title = $$cd_info{ title };
  my $num_tracks = $$cd_info{ num_tracks };

  for( my $i = 0; $i < $num_tracks; ++ $i ) {
    print( "$cd_id\t$cd_artist\t$cd_title\t",$i+1,"\t",
	   $$cd_info{ tracks }->{ $i },"\n" );
  }
  return( 1 );
}

my $cd_info = {};

while( <> ) {
  
  if( /\[(\S+)\]/ ) {
    my $id = $1;
    if( $$cd_info{ id } ) {
      dump_cd_info( $cd_info );
      $cd_info = {};
    }
    $$cd_info{ id } = $id;
  } elsif ( /artist=(.*)/ ) {
    $$cd_info{ artist } = $1;
  } elsif( /title=(.*)/ ) {
    $$cd_info{ title } = $1;
  } elsif( /numtracks=(\d+)/ ) {
    $$cd_info{ num_tracks } = $1;
  } elsif( /(\d+)=(.*)/ ) {
    $$cd_info{ tracks }->{ $1 } = $2;
  }
}

dump_cd_info( $cd_info );
      



#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

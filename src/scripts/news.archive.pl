#!/usr/local/bin/perl
#
# Title:        news.archive.pl
# Project:	Usenet
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	02/21/97 06:34
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

#
# create a tmp file to store the article in.
#

$tmpArtFn = "/home/Docs/news/news.arcive.$$";

open( TMP, "> $tmpArtFn" ) || die "open > $tmpArtFn: $!";

#
# read in the article and get it's 'archive-name'
#
while( <> )
  {
    print TMP $_;
    
    if( /^archive-name:\s+(\S+)/i )
      {
	$archiveFn = "/home/Docs/news/news.answers/$1";	
      }
  }

close( TMP );


if( $archiveFn )
  {
    use File::Basename;
    
    $archiveDir = dirname( $archiveFn );
    
    if( ! -d $archiveDir )
      {
	system( "mkdir -p $archiveDir" ) && die "mkdir -p $archiveDir: $!";
      } 

    unlink( "$archiveFn.gz" );

    rename( $tmpArtFn, $archiveFn ) ||
      die "rename( $tmpArtFn, $archiveFn ): $!";

    system( "gzip $archiveFn" ) &&
      die "system gzip $archiveFn: $!";
    
    print STDERR "article wrote to: $archiveFn\n";
  }
else
  {
    print STDERR "article not written:  no archive-name\n";
  }





#
# $Log$
# Revision 1.2  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
# Revision 1.1  1997/02/24 15:33:15  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

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


while( <> )
  {
    $article .= $_;

    if( /^archive-name:\s+(\S+)/i )
      {
	$archiveFn = "/usr/doc/news/news.answers/$1";	
      }
  }

# print "$archiveFn\n";

if( $archiveFn )
  {
    use File::Basename;
    
    $archiveDir = dirname( $archiveFn );
    
    if( ! -d $archiveDir )
      {
	system( "mkdir -p $archiveDir" ) && die "mkdir -p $archiveDir: $!";
      }
    
    open( ART, "> $archiveFn" ) || die "open( > $archiveFn";
    
    print ART $article;

    close( ART );

    print STDERR "article wrote to: $archiveFn\n";
  }
else
  {
    print STDERR "article not written:  no archive-name\n";
  }





#
# $Log$
# Revision 1.1  1997/02/24 15:33:15  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

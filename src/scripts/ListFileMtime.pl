#!/usr/bin/perl
#
# File:		ListFileMtime.pl
# Project:	Houghton
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     06/26/2012 13:50
# Copyright:   Copyright (c) 2012 Secure Media Keepers (www.SecureMediaKeepers.com)
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

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use File::Find;

sub FileFound {
  # print "$_\n";
  if( ! -f $_  || /.DS_Store/ || /.smk_sync/ ) {
    return;
  }
  my $fn = $File::Find::name;

  #print "FOUND: $fn\n";

  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
   $atime,$mtime,$ctime,$blksize,$blocks)
    = stat($_);

  printf( "%d~~%d~~%s\n",$mtime, $size, $fn );
}

foreach my $d (@ARGV) {
  if( -d $d ) {
    find( \&FileFound, $d );
  } else {
    print STDERR "Not a dir $d\n";
  }
}
	
## Local Variables:
## mode:perl
## end:

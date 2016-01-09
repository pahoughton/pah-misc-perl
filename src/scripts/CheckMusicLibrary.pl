#!/Support/bin/perl
#
# File:		CheckMusicLibrary.pl
# Project:	Music
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     03/01/2012 02:50
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
#use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
use File::Find;
#use MP4::File;
#use Meta::TMDb;
#use Meta::IMDB;
#use Term::ReadLine;
#use Data::Dumper;
#use POSIX;
#use Text::CSV;
#use DVD::Read;
#use Encode;
#use LWP;
#use MP4::Info;
#use XML::Parser;
#use Imager;
use SMK::Config;

my $smk_config = new SMK::Config;

#my $dbh = DBI->connect($smk_config->digit_db_dsn,
#                       $smk_config->digit_db_user,
#                       $smk_config->digit_db_pass,
#                       { RaiseError => 1, AutoCommit => 0 } );
#

my $ImportDir="/Users/paul/00-MediaWork/Audio/Was_iTunes_Media/Music";
my $CmacDir="/Public/Music/Library";
my $DroboDir="/Volumes/Drobo/Media/Audio/MusicLibrary/";

sub wanted {
  if( ! -f $_  || /.DS_Store/ || /.jpg$/ || /.png$/ ) {
    return;
  }
  my $fp = $File::Find::name;
  my $cmacFp = $fp;
  $fp =~ s~$CmacDir~~;
  if( ! -f "$DroboDir/$fp" ) {
    print "MISS: $fp\n";
  } else {
    my ($cdev,$cino,$cmode,$cnlink,$cuid,$cgid,$crdev,$csize,
     $catime,$cmtime,$cctime,$cblksize,$cblocks)
      = stat($_);
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	$atime,$mtime,$ctime,$blksize,$blocks)
      = stat("$DroboDir/$fp");

    if( $csize != $size ) {
      printf( "Size: %4d $fp\n",$csize - $size);
    }
  }
}

find( \&wanted, $CmacDir );

## Local Variables:
## mode:perl
## end:

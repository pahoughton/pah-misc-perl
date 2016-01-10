#!/Support/bin/perl
#
# File:		CheckAudioFiles.pl
# Project:	Audio
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     05/27/2012 04:42
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

#use DBI;
#use DBD::Pg qw(:pg_types);
use File::Basename;
use File::Find;
use Meta::Audio::File;
use iTunes::Library;
#use Meta::iTunes;
#use MP4::File;
#use Meta::TMDb;
#use Meta::IMDB;
#use Term::ReadLine;
use Data::Dumper;
#use POSIX;
#use Text::CSV;
#use DVD::Read;
#use Encode;
#use LWP;
#use MP4::Info;
#use XML::Parser;
#use Imager;
use URI::URL;
use SMK::Config;

my $smk_config = new SMK::Config;

#my $dbh = DBI->connect($smk_config->digit_db_dsn,
#                       $smk_config->digit_db_user,
#                       $smk_config->digit_db_pass,
#                       { RaiseError => 1, AutoCommit => 0 } );
#

my $MetaFile = new Meta::Audio::File;

my $FileSongs;

sub FNameToArtAlbSong {
  my ($fullfn) = @_;
  my $fname = basename( $fullfn );
  my $albDir = basename( dirname( $fullfn ) );
  my $artDir = basename( dirname( dirname( $fullfn ) ) );
  my $baseDir = dirname( dirname( dirname( $fullfn ) ) );
  return ($baseDir, $artDir,$albDir,$fname);
}

sub Found {
  if( ! /.mp3$/ && ! /.m4a/ ) {
    return;
  }
  print $File::Find::name."\n";
}

sub ProcMediaFile {
  my ($fullname) = @_;

  my ($baseDir, $artDir, $albDir, $fname) = FNameToArtAlbSong( $fullname );

  my $songMeta = $MetaFile->get_meta( $fullname );

  my $smDisc = (defined( $songMeta->disc_number()
			 ? $songMeta->disc_number()
			 : 1 ));

  my $metaKey = sprintf( "%s--%s--%02d-%02d %s"
			 ,( defined( $songMeta->album_artist )
			    ? $songMeta->album_artist
			    : $songMeta->artist )
			 ,$songMeta->album
			 ,$smDisc
			 ,$songMeta->track
			 ,$songMeta->title );
  my $fnKey = sprintf( "%s--%s--%s"
		       ,$artDir
		       ,$albDir
		       ,$fname );

  # print "$metaKey\n$fnKey\n";
  if( defined( $FileSongs->{ $fnKey } ) ) {
    printf( "FDUP: %s\n".
	    "      %s\n".
	    "      %s\n"
	    ,$fnKey
	    ,$FileSongs->{ $fnKey }->{ fn }
	    ,$fullname );
  } else {
    $FileSongs->{ $fnKey }->{ meta } = $songMeta;
    $FileSongs->{ $fnKey }->{ fn } = $songMeta;
  }

  if( $fnKey ne $metaKey ) {
    if( defined( $FileSongs->{ $metaKey } ) ) {
      printf( "MDUP: %s\n".
	      "      %s\n".
	      "      %s\n"
	      ,$metaKey
	      ,$FileSongs->{ $metaKey }->{ fn }
	      ,$fullname );
    } else {
      $FileSongs->{ $metaKey }->{ meta } = $songMeta;
      $FileSongs->{ $metaKey }->{ fn } = $fullname;
    }
  }
}
sub OrigFound {
  if( ! /.mp3$/ && ! /.m4a/ ) {
    return;
  }
  my $fullname = $File::Find::name;
  #print "$artDir -- $albDir -- $fname\n";
}
my $mvol = "/Volumes/SMKMedia";
my $MBDir = "$mvol/Media";
my $PMBDir = "$mvol/PersMedia";

#find( \&Found, "$MBDir/Audio/CD" );
#find( \&Found, "$MBDir/Audio/Digital" );
#find( \&Found, "$MBDir/Audio/Cassette" );
#find( \&Found, "$MBDir/Audio/LP" );

#find( \&Found, "$PMBDir/Audio/CD" );
#find( \&Found, "$PMBDir/Audio/Digital" );
#find( \&Found, "$PMBDir/Audio/Cassette" );
#find( \&Found, "$PMBDir/Audio/LP" );
#find( \&Found, "$PMBDir/Audio/Unknown" );

my $flistFN = "/Users/paul/00-SMKMedia.AllAudio.txt";
my $flistFH = undef;
open( $flistFH, "<", $flistFN )
  || die( "open $flistFN" );
while( <$flistFH> ) {
  chop;
  ProcMediaFile( $_ );
}
die( "test" );
my $cmac_iTunes = new iTunes::Library( "/Users/paul/00-MediaWork/Audio/Playlists/20120516.Cmac.iTunesLib.xml" );

my $cmac_playlists = $cmac_iTunes->playlists();
my $cmac_tracks = $cmac_iTunes->tracks();

my $cmac_plist_count = @$cmac_playlists;
print "Num Playlists $cmac_plist_count\n";

my $cmac_Music_plist = undef;
foreach my $cmac_plist (@$cmac_playlists) {
  if( defined( $cmac_plist->{ 'Name' } )
    && $cmac_plist->{ 'Name' }->{ 'value' } eq "Music" ) {
    $cmac_Music_plist = $cmac_plist;
    print Dumper( $cmac_plist->{ 'Name' }->{ 'value' } ),"\n";
    last;
  }
  #print join(", ",keys( $cmac_plist ) ),"\n";
  #print( Dumper( $cmac_plist->{ 'Playlist ID' } ) );
}
if( ! defined( $cmac_Music_plist ) ) {
  die( "Music playlist not found" );
}
foreach my $cmac_item ( @{$cmac_Music_plist
			    ->{ 'Playlist Items' }
			    ->{ 'value' }} ) {
  #print Dumper( $cmac_item );
  my $cmac_song = $cmac_tracks->song( $cmac_item
				      ->{ 'Track ID' }
				      ->{ value } );

  my $loc_url = new URI::URL( $cmac_song
			      ->{ Location }
			      ->{ value } );

  my $disc = $cmac_song->disc ? $cmac_song->disc : 1;

  my $metaKey = sprintf( "%s--%s--%02d-%02d %s"
			 ,( defined( $cmac_song->album_artist )
			    ? $cmac_song->album_artist
			    : $cmac_song->artist )
			 ,$cmac_song->album
			 ,$disc
			 ,$cmac_song->track
			 ,$cmac_song->title );
  if( ! defined( $FileSongs->{ $metaKey } ) ) {
    print "Not found $metaKey\n  ".$cmac_song->filename."\n";
  }
  #print Dumper( $cmac_song );
  #die( 'test' );
}

#print Dumper( $cmac_Music_plist );

die( "test" );

# $cmac_iTunes->dump_lib();




## Local Variables:
## mode:perl
## end:

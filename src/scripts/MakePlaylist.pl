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
my $mvol = "/Volumes/SMKMedia";
my $MBDir = "$mvol/Media";
my $PMBDir = "$mvol/PersMedia";
my $tfn = "/Volumes/SMKMedia/PersMedia/Video/TV/MusicVideos/Various Artists/Romeo Must Die Soundtrack/01-01 Try Again.mp4";
if( ! -f $tfn ) {
  die( $tfn );
}

my @AudioDirs = ( "$MBDir/Audio/CD"
		  ,"$MBDir/Audio/Digital"
		  ,"$MBDir/Audio/Cassette"
		  ,"$MBDir/Audio/LP"
		  ,"$PMBDir/Audio/CD"
		  ,"$PMBDir/Audio/Digital"
		  ,"$PMBDir/Audio/Cassette"
		  ,"$PMBDir/Audio/LP"
		  ,"$PMBDir/Audio/Unknown"
		  );

my $MetaFile = new Meta::Audio::File;

my $FileSongs;

sub FixFilename {
  my ($fname) = @_;
  if( defined( $fname ) ) {
    $fname =~ s/^\./_/;
    $fname =~ s/[:;,_\.\?\/!\[\]]+/_/g;
  }
  return $fname;
}

sub FNameToArtAlbSong {
  my ($fullfn) = @_;
  my $fname = basename( $fullfn );
  my $albDir = basename( dirname( $fullfn ) );
  my $artDir = basename( dirname( dirname( $fullfn ) ) );
  my $baseDir = dirname( dirname( dirname( $fullfn ) ) );
  return ($baseDir, $artDir,$albDir,$fname);
}

sub Found {
  if( ! /.mp3$/ && ! /.m4a$/ && ! /.mp4$/ ) {
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

my $plistBaseFname = "20120516.Cmac";
my $cmac_iTunes = new iTunes::Library( "/Users/paul/00-MediaWork/Audio/Playlists/20120516.Cmac.iTunesLib.xml" );

my $cmac_playlists = $cmac_iTunes->playlists();
my $cmac_tracks = $cmac_iTunes->tracks();

my $cmac_plist_count = @$cmac_playlists;
print "Num Playlists $cmac_plist_count\n";

my $cmac_Music_plist = undef;

open( ERRFH, ">", "$plistBaseFname.errors.txt" )
  || die( "open $plistBaseFname.errors.txt" );

foreach my $cmac_plist (@$cmac_playlists) {
  if( defined( $cmac_plist->{ 'Name' } )
      && ! defined( $cmac_plist->{ 'Distinguished Kind'} )
      && ! defined( $cmac_plist->{ 'Master' } )
      && ! defined( $cmac_plist->{ 'Folder' } )
      && ! defined( $cmac_plist->{ 'Smart Criteria' } ) ) {
    my $plistName = $cmac_plist->{ 'Name' }->{ value };
    print "$plistName\n";
    open( PLISTFH, ">","$plistBaseFname.$plistName.m3u" )
      || die( "open $plistBaseFname.$plistName.m3u" );
    print PLISTFH "#EXTM3U\n";
    print join( ", ",keys( %$cmac_plist ))."\n";
    foreach my $cmac_item ( @{$cmac_plist
				->{ 'Playlist Items' }
				  ->{ 'value' }} ) {
      my $cmac_song = $cmac_tracks->song( $cmac_item
					  ->{ 'Track ID' }
					  ->{ value } );
      if( $cmac_song->filename !~ /Music/ ) {
	next;
      }
      my ($baseDir, $artDir, $albDir, $fname)
	= FNameToArtAlbSong( $cmac_song->filename );

      my $trkNum = $cmac_song->track;
      if( ! defined( $cmac_song->track )
	&& $fname =~ /^(\d\d) / ) {
	$trkNum = $1;
      }
	
      my $ffname = "$artDir/$albDir/$fname";
      my $sfname = sprintf("%s/%s/%02d-%02d %s"
			   ,$cmac_song->album_artist
			   ,$cmac_song->album
			   ,( $cmac_song->disc
			      ? $cmac_song->disc
			      : 1 )
			   ,$trkNum
			   ,$cmac_song->title );
      my $csfname = sprintf("%s/%s/%02d-%02d %s"
			    ,FixFilename( $cmac_song->album_artist )
			    ,FixFilename( $cmac_song->album )
			    ,( $cmac_song->disc
			       ? $cmac_song->disc
			       : 1 )
			    ,$trkNum
			    ,FixFilename( $cmac_song->title ) );
      #$csfname =~ s/01-00 No One/01-04 No One/;
      #$csfname =~ s/01-00 Single White Female/01-01 Single White Female/;
      #$csfname =~ s/01-00 What Was I Thinkin/01-01 What Was I Thinkin/;
      #$csfname =~ s/01-00 Rough & Ready/01-11 Rough & Ready/;

      if( ! defined( $cmac_song->album_artist )
	  || ! defined( $cmac_song->album )
	  || ! defined( $cmac_song->track )
	  || ! defined( $cmac_song->title ) ) {
	;
      }
      my $s3fname = sprintf("%s.%s",$sfname,"mp3");
      my $s4fname = sprintf("%s.%s",$sfname,"m4a");
      my $svfname = sprintf("%s.%s",$sfname,"mp4");
      my $sv4fname = sprintf("%s.%s",$sfname,"m4v");
      my $cs3fname = sprintf("%s.%s",$csfname,"mp3");
      my $cs4fname = sprintf("%s.%s",$csfname,"m4a");
      my $csvfname = sprintf("%s.%s",$csfname,"mp4");
      my $csv4fname = sprintf("%s.%s",$csfname,"m4v");

      my $foundFn = undef;
      my $triedFns = "";
      if( $cmac_song->filename =~ /Video/ ) {
	foreach my $tfname ( $svfname
			     ,$sv4fname
			     ,$csvfname
			     ,$csv4fname) {
	  my $fpath = "$PMBDir/Video/TV/MusicVideos/$tfname";
	  if( -f $fpath ) {
	    $foundFn = $fpath;
	    last;
	  } else {
	    $triedFns .= "  T: ~$fpath~\n";
	    #print "$fpath\n";
	  }
	}
      } else {
	foreach my $bdir (@AudioDirs) {
	  foreach my $tfname ($s4fname
			      ,$s3fname
			      ,$cs3fname
			      ,$cs4fname ) {
	    my $fpath = undef;
	    if( $cmac_song->genre() =~ /OTR/ ) {
	      $fpath = "$bdir/OldTimeRadio/$tfname";
	    } else {
	      $fpath = "$bdir/Album/$tfname";
	    }
	    if( -f $fpath ) {
	      $foundFn = $fpath;
	      last;
	    } else {
	      $triedFns .= "  T: $fpath\n";
	      #print "$fpath\n";
	    }
	  }
	}
	if( defined( $foundFn ) ) {
	  last;
	}
      }

      if( ! defined( $foundFn ) ) {
	print( ERRFH
	       "NOT: $plistName $s4fname\n".
	       "  ".$cmac_song->filename."\n".
	       $triedFns );
      } else {
	printf(PLISTFH
	       "#EXTINF:%d,%s\n%s\n"
	       ,$cmac_song->seconds
	       ,$cmac_song->title
	       ,$foundFn );
	#print "$plistName: ".$cmac_song->filename."\n";
      }
    }
    close( PLISTFH );
  }
}
die( "TEST" );


my $flistFN = "/Users/paul/00-SMKMedia.AllAudio.txt";
my $flistFH = undef;
open( $flistFH, "<", $flistFN )
  || die( "open $flistFN" );
while( <$flistFH> ) {
  chop;
  ProcMediaFile( $_ );
}
die( "test" );
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

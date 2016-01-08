#!/Support/bin/perl
#
# File:		TagMusicVideos.pl
# Project:	Media
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     05/16/2012 13:20
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
use File::Basename;
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
sub FixFileName {
  my ($fname) = @_;
  $fname = s~^\.~_~;
  $fname = s~[/:\?\[\]\*]+~_~g;
  return $fname;
}

my $PMBDir = "/Volumes/SMKMedia/PersMedia";

my $MVRipDir = "Video/Rip/TV/MusicVideos";
my $MVRawDir = "Video/Raw/TV/MusicVideos";
my $MVConvDir = "Video/Conv/TV/MusicVideos";
my $MVFinalDir = "Video/TV/MusicVideos";

foreach my $mvRipDataFn (glob("$PMBDir/$MVRipDir/*/Data.txt")) {
  my $mvRipDir = dirname( $mvRipDataFn );
  my $mvRawDir = join("/"
		      ,$PMBDir
		      ,$MVRawDir
		      ,basename( dirname($mvRipDataFn) ) );


  rename( $mvRipDir, $mvRawDir )
    || die( "$? - mv $mvRipDir\nto $mvRawDir\n" );

  my $dataFh;
  open( $dataFh, "<", "$mvRawDir/Data.txt" )
    || die("open - $? - $mvRawDir/Data.txt");
  while( <$dataFh> ) {
    my $mvFn;
    my $albArtist;
    my $artist;
    my $alb;
    my $title;
    my $disc;
    my $track;
    my $reldate;
    my $genre;
    if( /FILE:\s+(\S.*mp4)/ ) {
      my $newMvFn = $1;
      if( defined( $mvFn ) ) {
	if( ! defined( $albArtist ) ) {
	  $albArtist = $artist;
	}
	if( ! defined( $albArtist )
	    || ! defined( $artist )
	    || ! defined( $alb )
	    || ! defined( $title )
	    || ! defined( $disc )
	    || ! defined( $track )
	    || ! defined( $reldate )
	    || ! defined( $genre )
	  ) {
	  printf( "Missing Meta: $mvFn\n"
		  ."  albart: %s\n"
		  ."     alb: %s\n"
		  ."    disc: %s\n"
		  ."   track: %s\n"
		  ."     art: %s\n"
		  ."   title: %s\n"
		  ." reldate: %s\n"
		  ."   genre: %s\n"
		  ,defined( $albArtist ) ? $albArtist : ""
		  ,defined( $alb ) ? $alb : ""
		  ,defined( $disc ) ? $disc : ""
		  ,defined( $track ) ? $track : ""
		  ,defined( $artist ) ? $artist : ""
		  ,defined( $title ) ? $title : ""
		  ,defined( $reldate ) ? $reldate : ""
		  ,defined( $genre ) ? $genre : ""
		  );
	} else {
	  my $titleFn = sprintf("%02d-%02d %s.mp4"
				,$disc
				,$title
				,FixFileName( $title ) );
	  my $artistSDir = FixFileName( $albArtist );
	  my $albSDir = FixFileName( $alb );

	  my $convMvFn = join( "/"
			       ,$PMBDir
			       ,$MVConvDir
			       ,$artistSDir );
	  my $finalMvFn = join( "/"
			       ,$PMBDir
			       ,$MVFinalDir
			       ,$artistSDir );

	  if( ! -d $convMvFn ) {
	    mkdir( $convMvFn ) || die( "mkdir $convMvFn" );
	  }
	  if( ! -d $finalMvFn ) {
	    mkdir( $finalMvFn ) || die( "mkdir $finalMvFn" );
	  }
	  $convMvFn = join( "/"
			    ,$convMvFn
			    ,$albSDir );
	  $finalMvFn = join( "/"
			    ,$finalMvFn
			    ,$albSDir );
	  if( ! -d $convMvFn ) {
	    mkdir( $convMvFn ) || die( "mkdir $convMvFn" );
	  }
	  if( ! -d $finalMvFn ) {
	    mkdir( $finalMvFn ) || die( "mkdir $finalMvFn" );
	  }
	  $convMvFn = join( "/"
			    ,$convMvFn
			    ,$titleFn );
	  $finalMvFn = join( "/"
			    ,$finalMvFn
			    ,$titleFn );
	  if( -f $convMvFn ) {
	    die( "$convMvFn exists" );
	  }
	  if( -f $finalMvFn ) {
	    die( "$finalMvFn exists" );
	  }

	  my @cpCmd( "cp"
		     ,"$mvRawDir/$mvFn"
		     ,$convMvFn );
	  if( system( @cpCmd ) ) {
	    die("$? - ",join("~",@cpCmd));
	  }
	  my @mp4tagCmd = ("mp4tags"
			   ,"-R" ,$albArtist
			   ,"-A" ,$alb
			   ,"-d" ,$disc
			   ,"-t" ,$track
			   ,"-a" ,$artist
			   ,"-s" ,$title
			   ,"-y" ,$reldate
			   ,"-g" ,$genre
			   ,$convMvFn );
	  if( system( @mp4tagCmd ) ) {
	    die("$? - ",join( "~",@mp4tagCmd));
	  }
	  my @gainCmd = ("aacgain"
			 ,"-r"
			 ,$convMvFn);
	  if( system( @gainCmd ) ) {
	    die("$? - ",join( "~",@gainCmd));
	  }
	  rename( $convMvFn, $finalMvFn )
	    || die("mv $convMvFn $finalMvFn");
	  print "Complete: $finalMvFn\n";
	}
      }
      $mvFn = $newMvFn;
      $albArtist = undef;
      $artist = undef;
      $alb = undef;
      $title = undef;
      $disc = undef;
      $track = undef;
      $reldate = undef;
      $genre = undef;

    } else if( /ALBARTIST:\s+(\S.*)\s*$/ ) {
      $albArtist = $1;

    } else if( /ALB:\s+(\S.*)\s*$/ ) {
      $alb = $1;

    } else if( /TITLE:\s+(\S.*)\s*$/ ) {
      $title = $1;

    } else if( /DISC:\s+(\S.*)\s*$/ ) {
      $disc = $1;

    } else if( /TRACK:\s+(\S.*)\s*$/ ) {
      $track = $1;

    } else if( /RELDATE:\s+(\S.*)\s*$/ ) {
      $reldate = $1;

    } else if( /GENRE:\s+(\S.*)\s*$/ ) {
      $genre = $1;

    }
  }
}


## Local Variables:
## mode:perl
## end:

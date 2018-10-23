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
# use Meta::Audio::File;
use iTunes::Library;
use Mac::PropertyList;
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
use Date::Calc qw(:all);

my $smk_config = new SMK::Config;

#my $dbh = DBI->connect($smk_config->digit_db_dsn,
#                       $smk_config->digit_db_user,
#                       $smk_config->digit_db_pass,
#                       { RaiseError => 1, AutoCommit => 0 } );
#

if( ! defined( $ARGV[0] ) ) {
  die "xml filename required\n";
}


my @VDirs = ( $ENV{HOME}."/Public"
	      ,"/Volumes/SMKMedia"
	      );

my @MADirs = ( "Audio/CD"
	      ,"Audio/Digital"
	      ,"Audio/Unknown"
	      ,"Audio/Cassette"
	    );
my @MVDirs = ( "Video/DVD"
	      ,"Video/VHS"
	      ,"Video/TV"
	      ,"Video/Digital"
	    );

my @AudDirs;
my @VidDirs;
my @MVidDirs;
{
  my $foundFn = undef; 
  my $triedFns = "";
  foreach my $vdir (@VDirs) {
    foreach my $mbdir ("Media","PersMedia") {
      foreach my $mdir (@MADirs) {
	foreach my $sdir ("Album","OldTimeRadio","Audiobooks") {
	  my $mediaDir = "$vdir/$mbdir/$mdir/$sdir";
	  if( -d $mediaDir ) {
	    # print "$mediaDir\n";
	    push( @AudDirs, $mediaDir );
	  }
	}
      }
    }
  }
  foreach my $vdir (@VDirs) {
    foreach my $mbdir ("Media","PersMedia") {
      foreach my $mdir (@MVDirs) {
	foreach my $sdir ("Movie","Documentary","TV") {
	  foreach my $adir ("4-3","16-9","1.85-1","2.40-1") {
	    my $mediaDir = "$vdir/$mbdir/$mdir/$sdir/$adir";
	    if( -d $mediaDir ) {
	      # print "$mediaDir\n";
	      push( @VidDirs, $mediaDir );
	    }
	  }
	}
      }
    }
  }

  foreach my $vdir (@VDirs) {
    foreach my $mbdir ("Media","PersMedia") {
      foreach my $mdir (@MVDirs) {
	my $mediaDir = "$vdir/$mbdir/$mdir/MusicVideos";
	if( -d $mediaDir ) {
	  # print "$mediaDir\n";
	  push( @MVidDirs, $mediaDir );
	} else {
	  #print "NO $mediaDir\n";
	}
      }
    }
  }
}

my $xmlFn = $ARGV[0];
my $plistBaseFname = basename( $xmlFn, ".xml" );

#my $libPlist = Mac::PropertyList::parse_plist_file( $xmlFn );
#print Dumper( $libPlist );
#die("TST");

my $iTunes = new iTunes::Library( $xmlFn );

my $tracks = $iTunes->tracks();
my $playlists = $iTunes->playlists();

my $trackCount = keys(%$tracks);
print "TRACK COUNT: $trackCount\n";

sub FixFilename {
  my ($fname) = @_;
  if( defined( $fname ) ) {
    $fname =~ s/^\./_/;
    $fname =~ s/[\":_\?\/\[\]]+/_/g;
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

sub FindMediaFile {
  my ($media) = @_;

  my $ffname;
  my $globfname = undef;
  my @fnames;

  if( $media->is_podcast() ) {
    my $searched = "";
    foreach my $vdir (@VDirs) {
      foreach my $mbdir ("Media","PersMedia") {
	my $fname = $media->filename();
	$fname =~ s~.*/Podcast/~$vdir/$mbdir/iTunes/Podcast/~;
	if( -f $fname ) {
	  return $fname;
	} else {
	  $searched .= "NOT: $fname\n";
	}
      }
    }
    print STDERR $searched;
    return undef;
  }
  if( $media->is_itunesu() ) {
    my $searched = "";
    foreach my $vdir (@VDirs) {
      foreach my $mbdir ("Media","PersMedia") {
	my $fname = $media->filename();
	$fname =~ s~.*/iTunes U/~$vdir/$mbdir/iTunes/iTunes U/~;
	if( -f $fname ) {
	  return $fname;
	} else {
	  $searched .= "NOT: $fname\n";
	}
      }
    }
    print STDERR $searched;
    return undef;
  }

  if( $media->is_movie() || $media->is_tv() ) {
    my $searched = "";
    foreach my $vdir (@VidDirs) {
      my $fname = "$vdir/".basename( $media->filename );
      if( -f $fname ) {
	return $fname;
      } else {
	$searched .= "NOT: $fname\n";
      }
    }
    if( $media->is_tv() ) {
      foreach my $vdir (@VDirs) {
	foreach my $mbdir ("Media","PersMedia") {
	  my $fname = $media->filename();
	  $fname =~ s~.*/TV Shows/~$vdir/$mbdir/iTunes/TV Shows/~;
	  if( -f $fname ) {
	    return $fname;
	  } else {
	    $searched .= "NOT: $fname\n";
	  }
	}
      }
    }
    #print STDERR $searched;
    return undef;
  }

  if( defined( $media->album ) ) {
    my ($baseDir, $artDir, $albDir, $fname)
      = FNameToArtAlbSong( $media->filename );

    my $discTrack  = "";
    my $title = $media->title;
    if( $fname =~ /^\d?\d?(\d\d)(\d\d)(\d\d) / ) {
      my $yy = $1;
      my $mNum = $2;
      my $dNum = $3;

      my $doy = Day_of_Year( "19$yy", $mNum, $dNum );
      $discTrack = sprintf("%02d-%03d "
			   ,$yy % 100
			   ,$doy );
      if( $title =~ /^19(\d\d)([0-1]\d)([0-3]\d) (.*)/ ) {
	my $yy = $1;
	my $mNum = $2;
	my $dNum = $3;
	$title = $4;
      }
    } elsif( $fname =~ /^\d\d \d\d(\d\d)(\d\d)(\d\d) / ) {
      my $yy = $1;
      my $mNum = $2;
      my $dNum = $3;

      my $doy = Day_of_Year( "19$yy", $mNum, $dNum );
      $discTrack = sprintf("%02d-%03d "
			   ,$yy % 100
			   ,$doy );

      if( $title =~ /^19(\d\d)([0-1]\d)([0-3]\d) (.*)/ ) {
	my $yy = $1;
	my $mNum = $2;
	my $dNum = $3;
	$title = $4;
      }
    } elsif( $title =~ /^19(\d\d)([0-1]\d)([0-3]\d) (.*)/ ) {
      my $yy = $1;
      my $mNum = $2;
      my $dNum = $3;
      $title = $4;
      my $doy = Day_of_Year( "19$yy", $mNum, $dNum );
      $discTrack = sprintf("%02d-%03d "
			   ,$yy % 100
			   ,$doy );


    } elsif( $fname =~ /^\d\d / ) {
      my $dNum = ( defined( $media->disc_num )
		   ? $media->disc_num
		   : 1 );
      my $tNum = ( defined( $media->track_num )
		   ? $media->track_num
		   : 0 );
      $discTrack = sprintf("%02d-%02d "
			   ,$dNum
			   ,$tNum );
      $fname = sprintf( "%02d-%s",$dNum,$fname );
    } else {
      my $dNum = ( defined( $media->disc_num )
		   ? $media->disc_num
		   : 1 );
      my $tNum = ( defined( $media->track_num )
		   ? $media->track_num
		   : 0 );
      $discTrack = sprintf("%02d-%02d "
			   ,$dNum
			   ,$tNum );
    }

    $ffname = "$artDir/$albDir/$fname";
    my $sfname = sprintf("%s/%s/%s%s"
			 ,$media->album_artist
			 ,$media->album
			 ,$discTrack
			 ,$title );

    my $csfname = sprintf("%s/%s/%s%s"
			  ,FixFilename( $media->album_artist )
			  ,FixFilename( $media->album )
			  ,$discTrack
			  ,FixFilename( $title ) );
    my $globArtist = $media->album_artist;
    my $globAlbum = $media->album;
    my $globTitle = $media->title;
    $globArtist =~ s/[ .\[\]:;]+/*/g;
    $globAlbum  =~ s/[ .\[\]:;]+/*/g;
    $globTitle  =~ s/[ .\[\]:;]+/*/g;

    $globfname =  "$globArtist*/$globAlbum*/*$globTitle*";

    $csfname =~ s~Christina Aguilera//01-05 Come On Over \(All I Want Is You\)~Christina Aguilera/Christina Aguilera/01-05 Come on Over~;
    $csfname =~ s~The Best Of Eric Clapton 20th Century Masters The Millennium Collection/01-06 Cocaine~Slowhand/01-01 Cocaine~;
    $csfname =~ s~Hank Williams, Jr./That's How They Do It In Dixie - The Essential Collection/01-01 That's How They Do It In Dixie~Hank Williams Jr./That's How They Do It in Dixie_ The Essential Collection/01-01 That's How They Do It In Dixie~;
    $csfname =~ s~Unwritten/01-03 Unwritten~Unwritten/01-04 Unwritten~;
    $csfname =~ s~01-10 Say It Right~01-08 Say It Right~;
    $csfname =~ s~Dreaming Out Loud/01-04 Apologize~Dreaming Out Loud \(Bonus Track Version\)/01-04 Apologize~;
    $csfname =~ s~The Pussycat Dolls/Music From the Motion Picture~Various Artists/Shall We Dance~;
    $csfname =~ s~In Love and War~In Love & War~;
    $csfname =~ s~Bee Gees/Saturday Night~Various Artists/Saturday Night~;
    $csfname =~ s~Boys Like Girls//~Boys Like Girls/Love Drunk/~;
    $csfname =~ s~Opps~Oops~;
    $csfname =~ s~Christina Aguilera/Shark Tale~Various Artists/Shark Tale~;
    $csfname =~ s~Litttle Bit of Life~Little Bit of Life~;
    $csfname =~ s~Did I Shave My Legs For This_~Did I Shave My Legs For This~;
    $csfname =~ s~01-07 Little Lies~01-12 Little Lies~;
    $csfname =~ s~01-02 You Make Me Feel Like Dancing~01-01 You Make Me Feel Like Dancing~;
    $csfname =~ s~Pocketful of Sunshine~Pocket Full Of Sunshine~;
    $csfname =~ s~Live At Irving Plaza 4.18.06/01-03~Electric Rodeo/01-02~;
    $csfname =~ s~#1s/01-05~Talking Book/01-06~;
    $csfname =~ s~01-01 Courtesy of the Red, White and Blue \(The Angry American\)~01-01 Courtesy Of The Red, White & Blue~;
    $csfname =~ s~Tyra B\.~Tyra B~;
    $csfname =~ s~Flashback_ The Best of .38 Special/01-02 Hold on Loosely~38 Special_ Anthology/01-04 Hold on Loosely~;
    $csfname =~ s~Flashback_ The Best of .38 Special/01-05 Caught Up in You~38 Special_ Anthology/01-10 Caught Up in You~;
    $csfname =~ s~A Little South of Sanity \(Live\)~A Little South of Sanity - Live~;
    $csfname =~ s~Opps~Oops~;
    $csfname =~ s~Up! \(Red Album\)~Up!~;
    $csfname =~ s~Alan Jackson & George Strait/Drive~Alan Jackson/Drive~;
    $csfname =~ s~01-01 Roundabout~01-05 Roundabout~;
    $csfname =~ s~Roland the Headless Thompson G~Roland the Headless Thompson Gunner~;
    $csfname =~ s~van_morrison-domino~Domino~;
    $csfname =~ s~Something Anything_~Something Anything~;
    $csfname =~ s~01-11 Stuck In The Middle With You~01-02 Stuck In The Middle With You~;
    $csfname =~ s~A Fine Frenzy/Dan In Real Life Soundtrack~Various Artists/Dan In Real Life Soundtrack~;
    $csfname =~ s~Aaron Neville/Phenomenon Soundtrack~Various Artists/Phenomenon Soundtrack~;
    $csfname =~ s~\@\#\%\&\*! Smilers~Smilers~;
    $csfname =~ s~Arno Jochem & Digz/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~\(Album Version\)~~;
    $csfname =~ s~Basia/Clear Horizon~Basia/Clear Horizon_ The Best of Basia~;
    $csfname =~ s~Berlin/Top Gun Soundtrack~Various Artists/Top Gun Soundtrack~;
    $csfname =~ s~Bryan Adams/Hope Floats Soundtrack~Various Artists/Hope Floats Soundtrack~;
    $csfname =~ s~Bryan Adams/Robin Hood~Various Artists/Robin Hood~;
    $csfname =~ s~Dave Grusin & Michelle Pfeiffer/The Fabulous Baker Boys Soundtrack~Various Artists/The Fabulous Baker Boys Soundtrack~;
    $csfname =~ s~Dave Grusin/The Fabulous Baker Boys Soundtrack~Various Artists/The Fabulous Baker Boys Soundtrack~;
    $csfname =~ s~Diana Krall/De-Lovely Soundtrack~Various Artists/De-Lovely Soundtrack~;
    $csfname =~ s~01-16 Suspicious Minds~01-27 Suspicious Minds~;
  
    $csfname =~ s~Emmylou Harris/Where the Heart Is Soundtrack~Various Artists/Where the Heart Is Soundtrack~;
    $csfname =~ s~Eric Carmen/Dirty Dancing~Various Artists/Dirty Dancing~;
    $csfname =~ s~Eric Weissberg/Deliverance Soundtrack~Various Artists/Deliverance Soundtrack~;
    $csfname =~ s~Gerald Albright & Lee Ritenour/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Collection/01-06 Neither One of Us~Collection/01-09 Neither One of Us~;
    $csfname =~ s~01-14 What Are You Doing the Rest of Your Life_~01-14 What Are You Doing the Rest of Your Life~;
    $csfname =~ s~02-08 Not While I'm Around~02-30 Not While I'm Around~;
    $csfname =~ s~02-12 Children Will Listen~02-34 Children Will Listen~;
    $csfname =~ s~02-13 As If We Never Said Goodbye~02-35 As If We Never Said Goodbye~;
    $csfname =~ s~02-14 I Finally Found Someone~02-36 I Finally Found Someone~;
    $csfname =~ s~02-15 Tell Him~02-37 Tell Him~;
    $csfname =~ s~02-16 I've Dreamed Of You~02-38 I've Dreamed Of You~;
    $csfname =~ s~02-17 Someday My Prince Will Come~02-39 Someday My Prince Will Come~;
    $csfname =~ s~02-18 You'll Never Walk Alone~02-40 You'll Never Walk Alone~;
    $csfname =~ s~02-27 Papa, Can You Hear Me_~02-27 Papa, Can You Hear Me~;
    $csfname =~ s~Chronicle_ 20 Greatest Hits~Chronicle, Vol. 1~;
    $csfname =~ s~01-01 Coming Out of the Dark~01-10 Coming Out of the Dark~;
    $csfname =~ s~Fleetwood Mac/01-07 The Chain~Fleetwood Mac/02-01 The Chain~;
    $csfname =~ s~Survival/01-05 Feelin~Survival/01-04 Feelin~;
    $csfname =~ s~The Definitive Collection/01-07 Emotion~The Definitive Collection/01-12 Emotion~;
    $csfname =~ s~The Heart Of Rock & Roll \(Single Edit\)~The Heart Of Rock & Roll~;
    $csfname =~ s~I Want A New Drug \(Single Edit\)~I Want A New Drug~;
    $csfname =~ s~Jonathan Butler/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Joe Sample & Michael Franks/Spellbound~Joe Sample/Spellbound~;
    $csfname =~ s~Lee Ritenour & Dave Grusin/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Lee Ritenour & Maxi Priest/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Lee Ritenour & Will Downing/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Linda Ronstadt & Aaron Neville/Cry Like a Rainstorm~Linda Ronstadt/Cry Like a Rainstorm~;
    $csfname =~ s~01-08 When Will I Be Loved_~01-08 When Will I Be Loved~;
    $csfname =~ s~Richie/01-00 My Love~Richie/01-04 My Love~;
    $csfname =~ s~Marc Antoine & Patti Austin/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Maroon 5/Songs About Jane/01-17 Sunday Morning~Maroon 5/Songs About Jane/01-08 Sunday Morning~;
    $csfname =~ s~Chet Baker/Playing By Heart~Various Artists/Playing By Heart~;
    $csfname =~ s~Mambo Italiano/01-00 Mambo Italiano~Mambo Italiano/01-01 Mambo Italiano~;
    $csfname =~ s~01-15 Cruisin' \(Single Edit\)~01-15 Cruisin'~;
    $csfname =~ s~Lisa Fischer/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~My Guy/01-21 My Guy~My Guy/01-04 My Guy~;
    $csfname =~ s~Left To Lose/01-01 Nothing Left~Left To Lose/01-02 Nothing Left~;
    $csfname =~ s~Through The Eyes Of Love \(Theme From The Motion Picture _Ice Castles_\)~Through The Eyes Of Love~;
    $csfname =~ s~Michael Brecker & Lisa Fischer/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Contraband/01-01 Who Can It Be Now_~Contraband/01-01 Who Can It Be Now~;
    $csfname =~ s~Michael Bubl.*/Call Me Irresponsible/~Michael Buble/Call Me Irresponsible/~;
    $csfname =~ s~Michael Brecker & Various Artists/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Minnie Riperton/01-14 Lovin~Minnie Riperton/01-05 Lovin~;
    $csfname =~ s~^Moody Blues~The Moody Blues~;
    $csfname =~ s~Hot August Night/01-02 Cherry, Cherry~Hot August Night/01-06 Cherry, Cherry~;
    $csfname =~ s~Moods/01-04 Play Me~Moods/01-06 Play Me~;
    $csfname =~ s~September Morn/01-12 September Morn~September Morn/01-01 September Morn~;
    $csfname =~ s~Serenade/01-80 Longfellow~Serenade/01-05 Longfellow~;
    $csfname =~ s~Singer/01-13 Love on the Rocks~Singer/01-04 Love on the Rocks~;
    $csfname =~ s~Flowers/01-03 Forever in Blue Jeans~Flowers/01-02 Forever in Blue Jeans~;
    $csfname =~ s~01-05 Feelin\' Way Too Damn Good~01-05 Feeling Way Too Damn Good~;
    $csfname =~ s~Dreaming/01-01 Still the One~Dreaming/01-06 Still the One~;
    $csfname =~ s~Lace/01-06 Billy Don\'t Be A Hero~Lace/01-02 Billy Don\'t Be A Hero~;
    $csfname =~ s~Classic Hits/01-19 Track  19~Classic Hits/01-01 (You\'re) Having My Baby~;
    $csfname =~ s~Peaches And Herb/The Best of Peaches~Peaches & Herb/The Best of Peaches~;
    $csfname =~ s~Phil Perry/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Greatest Hits - Queen/01-01 Somebody to Love~Greatest Hits - Queen/01-05 Somebody to Love~;
    $csfname =~ s~Saving Abel/01-02 Goodbye, So Long~Saving Abel/01-12 Goodbye, So Long~;
    $csfname =~ s~Jr./Greatest Songs_ Sammy Davis, Jr.~Jr_/Greatest Songs_ Sammy Davis, Jr_~;
    $csfname =~ s~Ronnie Milsap/Inside/02-01 Any Day Now~Ronnie Milsap/Inside/02-01 Any Day Now~;
    $csfname =~ s~Reunion/Barry Williams Presents_ One-Hit Wonders of the 70s/01-05 Life Is a Rock \(But the Radio Rolled Me\)~Various Artists/Barry Williams Presents_ One-Hit Wonders of the 70s/01-05 Life Is a Rock (But the Radio Rolled Me)~;
    $csfname =~ s~Richard Bona & Michael Brecker/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Rick Braun & Various Artists/A Twist of Marley~Various Artists/A Twist of Marley~;
    $csfname =~ s~Jack Webb/Dragnet~Dragnet/Dragnet~;
    $csfname =~ s~Bangles/Less Than Zero~Various Artists/Less Than Zero~;
    $csfname =~ s~Jack White & Alicia Keys/Quantum Of Solace~Various Artists/Quantum Of Solace~;
    $csfname =~ s~Ira Newborn/Dragnet~Various Artists/Dragnet~;
    $csfname =~ s~Beaver Brown/Eddie And The Cruisers~Various Artists/Eddie And The Cruisers~;
    $csfname =~ s~Benny Goodman/Sing Sing Sing~Benny Goodman/Benny Goodman Singles~;
    $csfname =~ s~The Who/Tommy/02~The Who/Tommy/01~;
    $csfname =~ s~Natalie Cole & Nat King Cole/Stardust/01~Natalie Cole/Stardust/01~;
    $csfname =~ s~01-17 Small World \(Single Edit\)~01-17 Small World~;
    $csfname =~ s~Al Jolson & The Andrew Sisters/Decca~Al Jolson/Decca~;
    $csfname =~ s~The News/01-05 Stuck With You \(Single Edit\)~The News/01-05 Stuck With You~;
    $csfname =~ s~Costello/01-00 Kids Program With Red Rider~Costello/48-255 Kids Program With Red Ryder~;
    $csfname =~ s~Avant & Nicole Scherzinger/Director~Avant/Director~;
    $csfname =~ s~Strange Magic_ The Best~Strange Magic - The Best~;
    $csfname =~ s~Benny Goodman/There\'ll Be Some Changes Made~Benny Goodman/Benny Goodman Singles~;
    $csfname =~ s~The Mamas & the Papas/The Papas & The Mamas~The Papas & the Mamas/The Papas & The Mamas~;
    $csfname =~ s~Bing Crosby/Dinah~Bing Crosby/Singles~;
    $csfname =~ s~Benny Goodman/Somebody Stole My Gal~Benny Goodman/Benny Goodman Singles~;
    $csfname =~ s~Christmas Classics/01-03 (Medley) What Child Is This_The Holly And The Ivy~Christmas Classics/01-03 (Medley) What Child Is This__The~;
    $csfname =~ s~01-03 \(Medley\) What Child Is This_The Holly And The Ivy~01-03 (Medley) What Child Is This__The~;
    $csfname =~ s~Christmas/02-14 A Crosby Christmas, Pt. 2_ The Snowman_That Christmas Feeling_I\'d Like To~Christmas/02-14 A Crosby Christmas, Pt. 2_ The~;
    $csfname =~ s~Emmylou Harris & Don Williams/Cimarron~Emmylou Harris/Cimarron~;
    $csfname =~ s~Jennifer Lopez & Fat Joe/Rebirth~Jennifer Lopez/Rebirth~;
    $csfname =~ s~Eddie Money/Can'r Hold~Eddie Money/Can't Hold~;
    $csfname =~ s~War/01-03 New Year's Day - U2.mp3~War/01-03 New Year's Day~;
    $csfname =~ s~War/Why Can't We Be Friends_~War/Why Can't We Be Friends~;
    $csfname =~ s~Jennifer Lopez & Big Pun, Fat Joe/On the 6~Jennifer Lopez/On the 6~;
    $csfname =~ s~Bone Thugs-n-Harmony & Akon/Strength~Bone Thugs-n-Harmony/Strength~;
    $csfname =~ s~Peacocks/It's Time/01-11 A Song~Michael Buble/It's Time/01-11 A Song~;
    $csfname =~ s~Louis Armstrong & Ella Fitzgerald/What A Wonderful~Louis Armstrong/What A Wonderful~;
    $csfname =~ s~from Pain/01-00 We Live~from Pain/01-10 We Live~;
    $csfname =~ s~Little Voice/01-00 Love Song~Little Voice/01-01 Love Song~;
    $csfname =~ s~Ashlee Simpson & Tom Higgenson/Bittersweet World~Ashlee Simpson/Bittersweet World~;
    $csfname =~ s~01-18 Christmas Carols_ Good King Wenceslas_We Three Kings of Orient Are_Ange~01-18 Christmas Carols_ Good King Wen~;
    $csfname =~ s~December/01-03 Let It Snow! Let It Snow! Let~December/01-03 Let It Snow~;
    $csfname =~ s~Natasha Bedingfield/Pocket Full Of Sunshine~Natasha Bedingfield/Pocket Full Of Sunshine~;
    $csfname =~ s~Elton John & George Michael/Duets~Elton John/Duets~;
    $csfname =~ s~Lady Antebellum/01-00 Lookin~Lady Antebellum/01-02 Lookin~;
    $csfname =~ s~Bedingfield/Pocketful Of Sunshine~Bedingfield/Pocket Full Of Sunshine~;
    $csfname =~ s~01-17 The Saints Are Coming \(Live from New Orleans\)~01-17 The Saints Are Coming~;
    $csfname =~ s~Jack's Mannequin & Stacy Clark/The Glass~Jack's Mannequin/The Glass~;
    $csfname =~ s~Ashlee Simpson & Izza Kizza/Bittersweet~Ashlee Simpson/Bittersweet~;
    $csfname =~ s~Singles Collection \(3\)/01-02~Singles Collection (3)/01-02~;
    $csfname =~ s~Emmylou Harris, Dolly Parton & Linda ronstadt/Portraits~Emmylou Harris/Portraits~;
    $csfname =~ s~Courtesy Of The Red, White & Blue~Courtesy Of The Red, White and Blue~;
    $csfname =~ s~The Complete Capitol Singles Collection \(3\)~The Complete Capitol Singles Collection~;
    $csfname =~ s~Three Dog Night_ The Complete Hit Singles~Three Dog Night - The Complete Hit Singles~;
    $csfname =~ s~Tommy Can You Hear Me_~Tommy Can You Hear Me~;
    $csfname =~ s~The Black Eyed Peas/iTunes Originals - Black Eyed Peas/01-12 Where Is the Love_ \(iTunes Originals Version\)~Black Eyed Peas/Elephunk/01-13 Where Is the Love~;
    $csfname =~ s~We're All Alone \(Live\)~We're All Alone~;
    $csfname =~ s~You're  In Kentucky~You're In Kentucky~;
    $csfname =~ s~Blondie \& The Doors/Greatest~Blondie/Greatest~;
    $csfname =~ s~Dave Koz \& India Arie/At The Movies~Dave Koz/At The Movies~;
    $csfname =~ s~City High \& Eve/City High~City High/City High~;
    $csfname =~ s~Hope Floats Soundtrack/01-00 When~Hope Floats Soundtrack/01-12 When~;
    $csfname =~ s~17 Christmas Carols_ Deck the Halls_Away in a Manger_I Saw Three Ships~17 Christmas Carols_ Deck the Hall~;
    $csfname =~ s~About Jane/01-00 This Love~About Jane/01-02 This Love~;
    $csfname =~ s~Legs For This/01-00 Strawberry Wine~Legs For This/01-08 Strawberry Wine~;
    $csfname =~ s~Calling Occupants Of Interplanetary Craft \(The Recognized Anthem Of World Contact Day\)~Calling Occupants Of Interplanetary Craft~;
    $csfname =~ s~Live/01-01 Lowdown \(Live\)~Live/01-01 Lowdown~;
    $csfname =~ s~01-07 What Child Is This_The Holly and the Ivy~01-07 What Child Is This\?_The Holly and the Ivy~;
    $csfname =~ s~Benny Goodman/Don\'t Be That Way~Benny Goodman/Benny Goodman Singles~;
    $csfname =~ s~Benny Goodman/Taking A Chance On Love~Benny Goodman/Benny Goodman Singles~;
    $csfname =~ s~The News/01-12 I Know What I Like \(Single Edit\)~The News/01-12 I Know What I Like~;
    $csfname =~ s~Benny Goodman/Lets Dance/01-00 Lets Dance~Benny Goodman/Benny Goodman Singles/01-00 Lets Dance~;
    
    
    
    $csfname =~ s~\s+$~~;
    push( @fnames, $sfname, $csfname );

  } else {
    $ffname = basename( $media->filename() );
  }
  my @mdirs;
  my @mexts;
  my @msub;
  if( $media->is_music_video() ) {
    @mexts = (".mp4",".m4v");
    @mdirs = @MVidDirs;
  } else {
    @mdirs = @AudDirs;
    @mexts = (".m4a",".mp3");
  }

  #print STDERR "fns ",@fnames,"\next ",@mexts,"\n";
  my $foundFn = undef;
  my $searchedFn = "";
  foreach my $mdir (@mdirs) {
    if( -f "$mdir/$ffname" ) {
      $foundFn = "$mdir/$ffname";
      return( $foundFn );
    } else {
      $searchedFn .= "NOTF: $mdir/$ffname\n";
      foreach my $fname (@fnames) {
	foreach my $mext (@mexts) {
	  my $mfname = "$mdir/$fname$mext";
	  if( -f $mfname ) {
	    $foundFn = $mfname;	
	    return $foundFn;
	  }
	  $searchedFn .= "NOT: $mfname\n";
	}
      }
      if( defined( $globfname ) ) {
	my @gFound = glob( "$mdir/$globfname" );
	my $gFoundCnt = @gFound;
	if( $gFoundCnt == 1 ) {
	  $foundFn = $gFound[0];
	  last;
	} else {
	  $searchedFn .= "NOTG: $mdir/$globfname\n";
	}
      }
    }
  }
  if( ! defined( $foundFn ) ) {
    printf( STDERR "NOT %s\n",join( "\n    ", @fnames ) );;
  }
  return $foundFn;
}

my $Ratings;

foreach my $trkKey (keys( %$tracks )) {
  my $media = $tracks->song( $trkKey );
  my $rating = $media->rating();
  my $songFn = $media->filename();
  if( ! defined( $songFn ) ) {
    die( "NO FN: ".Dumper( $media ) );
    next;
  }
  $songFn = FindMediaFile( $media );
  if( ! defined( $songFn ) ) {
    print ( STDERR "NOT FOUND ".$media->filename."\n" );
  }
  $media->{ foundFn } = $songFn;
  # print "FOUND: $songFn\n";
  if( defined( $rating ) ) {
    if( ! defined( $Ratings->{ $rating } ) ) {
      $Ratings->{ $rating }->[0] = $media;
    } else {
      push( $Ratings->{ $rating }, $media );
    }
  }
}

foreach my $ratingKey (keys(%$Ratings)) {
  open( RFH, ">", "$plistBaseFname.R$ratingKey.m3u" )
    || die( "open $plistBaseFname.R$ratingKey.m3u" );
  print RFH "#EXTM3U\n";
  foreach my $rSong (@{$Ratings->{ $ratingKey }}) {
    my $songFn = $rSong->{ foundFn };
    if( ! defined( $songFn ) ) {
      next;
    }
    printf(RFH
	   "#EXTINF:%d,%s\n%s\n"
	   ,$rSong->seconds
	   ,$rSong->title
	   ,$songFn );
  }
  close( RFH );
}

foreach my $plist (@$playlists) { 
  my $plistName = $plist->{ 'Name' }->{ value };
  if( defined( $plist->{ 'Playlist Items' }->{ 'value' } ) ) {
    open( PLISTFH, ">","$plistBaseFname.$plistName.m3u" )
      || die( "open $plistBaseFname.$plistName.m3u" );
    print PLISTFH "#EXTM3U\n";
    my $plistCnt = 0;
    foreach my $plistItem ( @{$plist->{ 'Playlist Items' }->{ 'value' }} ) {
      my $song = $tracks->song( $plistItem->{ 'Track ID' }->{ value } );
      my $songFn = $song->{ 'foundFn' };
      if( ! defined( $songFn ) ) {
	next;
      }
      printf(PLISTFH
	     "#EXTINF:%d,%s\n%s\n"
	     ,$song->seconds
	     ,$song->title
	     ,$songFn );
      ++ $plistCnt;
    }
    close( PLISTFH );
    print "$plistName $plistCnt\n";
    # print join( ", ",keys( %$cmac_plist ))."\n";
  }
}
## Local Variables:
## mode:perl
## end:

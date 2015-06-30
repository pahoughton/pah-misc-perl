#!/opt/local/bin/perl
#
# File:		RipAudioCd.pl
# Project:	SMK Digit
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     03/19/2012 04:55
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
use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
#use File::Find;
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
use Class::Date;
use SMK::Config;

my $smk_config = new SMK::Config( server => 'test' );

my $MBaseDir = $smk_config->digit_media_basedir();
if( ! -d "$MBaseDir/Media/Rip" ) {
  die( "$MBaseDir/Media/Rip is not a directory" );
}
sub LogIt {
  print @_,"\n";;
  open( $logFh, ">>",$ENV{HOME}."/RipAudioCd.log");
  my $date = new Class::Date( time );
  my $dtStr = sprintf( "%02d%02d%02d %02d%02d%02d",
		       $date->yr,
		       $date->month,
		       $date->mday,
		       $date->hour,
		       $date->min,
		       $date->sec );
  print $logFh "$dtStr ".join( "\n",@_)."\n";
  close( $logFh );
}
sub Abort {
  LogIt( @_ );
  die;
}
LogIt( "Started Cmd: ".join( " ",@ARGV ) );

my $upc = undef;
if( ! defined( $ARGV[0] ) ) {
  print"Enter UPC: ";
  $upc = <>;
} else {
  $upc = $ARGV[0];
}
#die( "UPC: $upc\n" );

my $dbdg = DBI->connect($smk_config->digit_db_dsn,
			$smk_config->digit_db_user,
			$smk_config->digit_db_pass,
			{ RaiseError => 1, AutoCommit => 0 } );

my $dbmb = DBI->connect($smk_config->mbrainz_db_dsn,
                       $smk_config->digit_db_user,
                       $smk_config->digit_db_pass,
                       { RaiseError => 1, AutoCommit => 0 } );

my $RipDir = "/Volumes/Drobo/Media/Rip";
open( my $dskInfoFH, "-|", $ENV{HOME}."/bin/CdInfo" )
  || Abort "getting cdinfo";

my $cddrive;
my $mbid;
my $fdbid;
my $ftrk;
my $ltrk;
my $totSectors;
my $subURL;
my $wsURL;
my $tracks;
my $CdInfo = "";
while( <$dskInfoFH> ) {
  $CdInfo .= $_;
  if ( /CDDRV: (.*)/ ) {
    $cddrive = $1;
  } elsif ( /MBID: (.*)/ ) {
    $mbid = $1;
    $fdbid = undef;
    $ftrk = undef;
    $ltrk = undef;
    $totSectors = undef;
    $subURL = undef;
    $wsURL = undef;
    $tracks = undef;
  } elsif ( /FDBID: (.*)/ ) {
    $fdbid = $1;
  } elsif ( /FTRK: (.*)/ ) {
    $ftrk = $1;
  } elsif ( /LTRK: (.*)/ ) {
    $ltrk = $1;
  } elsif ( /TOTSECT: (\d+) sectors/ ) {
    $totSectors = $1;
  } elsif ( /SUBURL: (.*)/ ) {
    $subURL = $1;
  } elsif ( /WSURL: (.*)/ ) {
    $wsURL = $1;
  } elsif ( /TRK-(\d\d)-SECTOFF:\s+(\d+)/ ) {
    $tracks->{ $1 }->{ off } = $2;
  } elsif ( /TRK-(\d\d)-SECTLEN:\s+(\d+)/ ) {
    $tracks->{ $1 }->{ len } = $2;
  }
}
close( $dskInfoFH );


if( ! defined( $mbid )  ) {
  system( "diskutil eject '$cddrive'" );
  Abort "CD Read Error - Aborting\n";
}

$upc =~ s~[ -]*~~g;

my $alb_dir_name = "UPC~~$upc~~0";
my $sql;
my $dgSth;
my ($db_upc,$dsknum) = split( /_/,$upc);
$sql = "
SELECT DISTINCT sel_source, sel_source_id
FROM media_meta_selection
WHERE search_upc = $db_upc
";
$dgSth = $dbdg->prepare( $sql );
$dgSth->execute() || Abort( $sql );
if( $dgSth->rows() < 1 ) {
  system( "diskutil eject '$cddrive'" );
  Abort( "UPC '$upc' not found in media_meta_selection" );
} elsif( $dgSth->rows() > 1 ) {
  system( "diskutil eject '$cddrive'" );
  Abort( "Multiple meta selections for $upc" );
} else {
  my ($sel_src, $sel_src_id) = $dgSth->fetchrow_array();
  if( $sel_src eq "fdb_audio_albums" ) {
    $sql = "
SELECT alb_artist_name, alb_name
FROM fdb_audio_albums
WHERE fdb_aud_alb_id = $sel_src_id
";
  } elsif( $sel_src eq "audio_albums" ) {
    $sql = "
SELECT sel_aud_artist_name( alb_artist_id ) as alb_artist, alb_name
FROM audio_albums
WHERE aud_alb_id = $sel_src_id
";
  } else {
    system( "diskutil eject '$cddrive'" );
    Abort( "unsupported meta source $sel_src" );
  }
  my ($alb_artist, $alb_name ) = $dbdg->selectrow_array( $sql );
  if( ! defined( $alb_name ) ) {
    system( "diskutil eject '$cddrive'" );
    Abort( "meta info not found for $upc" );
  }
  $alb_dir_name = "$alb_artist~~$alb_name~~$upc";
}
# print "FDBID: $fdbid\n";
# print "ALBDIR: $alb_dir_name\n";
my $cdDir ="$MBaseDir/Media/Rip/$alb_dir_name.CD";

if( -d $cdDir ) {
  system( "diskutil eject '$cddrive'" );
  Abort( "CD directory '$cdDir' exists - Aborting\n" );
}
my $ripDir = "$MBaseDir/Media/Rip/$alb_dir_name.ripping_cd";
if( -d $ripDir ) {
  system( "diskutil eject '$cddrive'" );
  Abort( "CD Rip directory '$ripDir' exists - Aborting\n" );
}
# print "$ripDir\n";

mkdir $ripDir || Abort( "mkdir $ripDir" );
chdir $ripDir || Abort( "chdir $ripDir" );

my $ripStart = new Class::Date( time );
if( system("/Support/bin/cdparanoia -q -f -B -l") == 0 ) {
  my $ripEnd = new Class::Date( time );
  open( my $ripFh, ">","ripstats.txt") || Abort( "open ripstats" );
  printf( $ripFh "RIPSTART: %s\nRIPSTOP: %s\n",
	  $ripStart->string,
	  $ripEnd->string );
  close( $ripFh );
  open( my $diFh, ">", "discinfo.txt" ) || Abort("open discinfo");
  print $diFh "$CdInfo";
  close( $diFh );
  open( my $upcFh, ">", "upc.txt" ) || Abort( "open upc" );
  print $upcFh "UPC: $upc\n";
  close( $upcFh );

  rename( $ripDir, $cdDir );

  print "Rip Complete $cdDir\n";
  LogIt( "Rip complete $cdDir" );
  system( "diskutil eject '$cddrive'" );
} else {
  system( "diskutil eject '$cddrive'" );
  Abort("Error ripping cd - see log file");
}

## Local Variables:
## mode:perl
## end:

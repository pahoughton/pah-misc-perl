#!/Support/bin/perl
#
# File:		SMKSync.pl
# Project:	SMK Utils
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     04/05/2012 02:03
# Copyright:   Copyright (c) 2012 Secure Media Keepers (www.SecureMediaKeepers.com)
#
# Revision Info: (See ChangeLog or cvs log for revision history)
#
#	$Author: paul $
#	$Date: 2012/05/19 21:09:57 $
#	$Name:  $
#	$Revision: 1.1 $
#	$State: Exp $
#
# $Id: RmDups.pl,v 1.1 2012/05/19 21:09:57 paul Exp $
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
#use DBI;
#use DBD::Pg qw(:pg_types);
use File::Basename;
use File::Find;
use Cwd;
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
use SMK::Config;
use Log;

sub Found {

  if( ! -f $_ ) {
    return;
  }
  if( /.mp3$/ ) {
    return;
    my $tagFh;
    #print "$_\n";
    my $fn = $_;
    open( $tagFh, "id3info '$fn' |" )
      || die("id3info $fn" );
    my $albArtist = undef;
    my $meta = "";
    while( <$tagFh> ) {
      #print;
      $meta .= $_;
       if( /=== TPE2 \(Band\/orchestra\/accompaniment\): (\S.*)$/ ) {
 	$albArtist = $1;
 	last;
       }
    }
    if( ! defined( $albArtist ) ) {
      die("Missing alb artist:\n$meta\nfn: ".$File::Find::name );
    }
    #die( "Test" );
  } elsif( /.m4a/ || /.m4v/ || /.mp4/ ) {
    my $tagFh;
    open( $tagFh, "mp4Details '$_' }" )
      || die( "Fail: mp4Details $_" );
    my $albArtist = undef;
    my $meta = "";
    while( <$tagFh> ) {
      $meta .= $_;
    }
    if( ! defined( $albArtist ) ) {
      die("Missing alb artist:\n$meta\nfn: ".$File::Find::name );
    }
#     my $meta = new Meta::Audio::File;
#     my $trk = $meta->get_meta( $_ );
#     if( ! defined( $trk->album_artist ) ) {
#       print Dumper( $trk );
#       die("Missing alb artist ".$File::Find::name );
#     }
    # printf( "%s--%s--%s\n" ,$trk->artist ,$trk->album ,$trk->title );
    #die( "test $_" );
  } elsif( ! /.DS_Store/ ) {
    die( "Unexpected file: ".$File::Find::name );
  }
}

find( \&Found, "." );

## Local Variables:
## mode:perl
## end:

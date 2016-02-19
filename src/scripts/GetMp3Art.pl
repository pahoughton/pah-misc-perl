#!/Support/bin/perl
#
# File:		GetMp3Art.pl
# Project:	SMK Digit
# Desc:
#
#   
#
# Notes:
#
# Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
# Created:     03/02/2012 05:57
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
use Data::Dumper;
#use POSIX;
#use Text::CSV;
#use DVD::Read;
#use Encode;
#use LWP;
#use MP4::Info;
#use XML::Parser;
use Imager;
use MP3::Tag;
use SMK::Config;

my $smk_config = new SMK::Config;

#my $dbh = DBI->connect($smk_config->digit_db_dsn,
#                       $smk_config->digit_db_user,
#                       $smk_config->digit_db_pass,
#                       { RaiseError => 1, AutoCommit => 0 } );
#

my $ImageTypes;

sub wanted {
  if( ! -f $_ || ! /.mp3$/ ) {
    return;
  }
  my $fp = $File::Find::name;

  $mp3 = MP3::Tag->new($_);

  $mp3->get_tags();
  my $id3v2 = $mp3->{ID3v2};
  if( ! defined( $id3v2 ) ) {
    print "NO id3v2: $fp\n";
  } else {
    my ($info,$dscr) = $id3v2->get_frame("APIC");
    if( ! defined( $info ) ) {
      print "NO PIC: $fp\n";
    } elsif( ! defined( $info->{ "MIME type" } ) ) {
      print "NO Mime Type: $fp\n";
    } else {
      $ImageTypes->{ $info->{ "MIME type" } } = 1;
    }
#     print join( "\n", keys( %$info )),"\n";
#     foreach my $k (keys(%$info)) {
#       if( $k ne "_Data" ) {
# 	print "$k - ".$info->{ $k }."\n";
#       }
#     }
#     print $info->{ "MIME type" },"\n";
    # die;
  }
}

find(\&wanted, "/Volumes/Drobo/Media/Audio/MusicLibrary" );

foreach my $k (keys(%$ImageTypes)) {
  print "$k\n";
}

## Local Variables:
## mode:perl
## end:

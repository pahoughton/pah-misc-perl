#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP3::Tag;
use MP4::Info;

our @MP3_Tags = ("TALB", "TCON", "TIT2", "TPE1", "TRCK", "TYER", "APIC" );
our @ID3_V1_Tags = ("TAL", "TCO", "TT2", "TP1", "", "TYE", "PIC" );

our %MP3_V2_V1 = ( "TALB" => "album"
		   ,"TCON" => "genre"
		   ,"TIT2" => "title"
		   ,"TPE1" => "artist"
		   ,"TRCK" => "track"
		   ,"TYER" => "year"
		   ,"APIC" => "PIC" );

our @MP4_Tags = ("ALB", "ART", "COVR", "DAY", "GNRE", "NAM", "TRKN" );

sub wanted {
  my $fn = $_;
  my $fp = $File::Find::name;
  if( /.mp3$/ ) {
    my $tags = MP3::Tag->new( $fn );
    if( ! $tags ) {
      die "No tags: $fp";
    }
    my @found = $tags->get_tags();
    my @missing2;
    if( exists $tags->{ID3v2} ) {
      my $id3 = $tags->{ ID3v2 };
      foreach my $t (@MP3_Tags) {
	my ($tval,$tinfo) = $id3->get_frame( $t );
	if( ! $tval ) {
	  push( @missing2, $t );
	}
      }
    } else {
      push( @missing2, @MP3_Tags );
    }
    my @missing;
    if( @missing2 > 0 ) {
      if( exists $tags->{ID3v1} ) {
	my $id3 = $tags->{ID3v1};
	foreach my $t (@missing2) {
	  my ($tval,$tinfo) = $id3->get_frame( $MP3_V2_V1{$t} );
	  if( ! defined( $tval ) ) {
	    push( @missing, $t );
	  }
	}
      }
    } else {
      push( @missing, @missing2 );
    }
    if( @missing > 0 ) {
      print "$fp -- Missing: ",join( ", ",@missing ),"\n";
    }
  } elsif ( /.mp4$/ ) {
    my $tags = get_mp4tag( $fn );
    if(  $tags ) {
      my @missing;
      foreach my $t (@MP4_Tags) {
	if( ! $tags->{ $t } ) {
	  push( @missing, $t );
	}
      }
      my $ml = @missing;
      if( $ml > 0 ) {
	print "$fp -- Missing: ",join( ", ",@missing ),"\n";
      }
    } else {
      print "$fp -- Missing: TAGS\n";
    }
  }
}

find( \&wanted, "." );

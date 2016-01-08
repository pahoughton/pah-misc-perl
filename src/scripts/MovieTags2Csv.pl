#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP4::File;
use MP4::Info;

sub wanted {

  if( -f && $File::Find::name =~ /Movies.*\/(\d.*\d)\/(.*).mp4$/ ) {

    my $source = "VHS";
    if( -f && $File::Find::name =~ /Movies\/DVD.*\/(\d.*\d)\/(.*).mp4$/ ) {
      $source = "DVD";
    }
    my $asp_dir = $1;
    my $title = $2;
    my $aspect = undef;
    my $info = undef;
    my $mp4f = new MP4::File;
    if( $mp4f->Read( $_ ) ) {
      $info = $mp4f->Info( 1 );
    }
    my $ar;
    if( defined( $info ) && $info =~ /kbps, (\d+)x(\d+) / ) {
      my $vw = "$1.0";
      my $vh = "$2.0";
      $ar = $vw / $vh;
      if( $ar < 1.51 ) {
	$aspect = "4:3";
      } elsif ( $ar < 1.8 ) {
	$aspect = "16:9";
      } elsif ( $ar < 2.1 ) {
	$aspect = "1.85:1";
      } elsif ( $ar < 2.8 ) {
	$aspect = "2.40:1";
      } else {
	$aspect = undef;
      }
    }

    my $tag = get_mp4tag($_);
    if( $tag && $tag->{NAM} && $tag->{YEAR} ) {
      print( '"',$tag->{NAM},"\",",
	     $tag->{YEAR},",",
	     $source,",",
	     $aspect,"\n" );
    }
  }
}

find( \&wanted, "." );

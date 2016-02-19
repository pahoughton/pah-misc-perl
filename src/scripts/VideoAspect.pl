#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Find;
use File::Basename;
use MP4::Info;
use MP4::File;

foreach my $fn (@ARGV) {
  my $info = undef;
  my $mp4f = new MP4::File;
  if( $mp4f->Read( $fn ) ) {
    $info = $mp4f->Info( 1 );
  }
  my $aspect = undef;
  my $ar;
  if( defined( $info ) && $info =~ /kbps, (\d+)x(\d+) / ) {
    my $vw = "$1.0";
    my $vh = "$2.0";
    $ar = $vw / $vh;
    if( $ar < 1.5 ) {
      $aspect = "4:3";
    } elsif ( $ar < 1.8 ) {
      $aspect = "16:9";
    } elsif ( $ar < 2.1 ) {
      $aspect = "1.85:1";
    } elsif ( $ar < 2.5 ) {
      $aspect = "2.40:1";
    } else {
      $aspect = undef;
    }
  }
  print "$aspect $fn\n";
}

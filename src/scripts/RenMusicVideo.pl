#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP4::File;
use MP4::Info;

my $basedir = "/Users/paul/00-MediaWork/Audio/ForImport/Videos";

foreach my $fn (@ARGV) {
  my $tags = get_mp4tag( $fn );
  my $art = $tags->{ ARTIST };
  my $alb = $tags->{ ALBUM };
  my $trk = $tags->{ TRACKNUM };
  my $nam = $tags->{ TITLE };

  if( ! -d "$basedir/$art" ) {
    mkdir( "$basedir/$art" ) || die "mkdir $basedir/$art";
  }
  if( ! -d "$basedir/$art/$alb" ) {
    mkdir( "$basedir/$art/$alb" ) || die "mkdir $basedir/$art/$alb";
  }
  my $nfn = sprintf( "%02d $nam.mp4",$trk );
  print "$fn\n$basedir/$art/$alb/$nfn\n";
  rename( $fn, "$basedir/$art/$alb/$nfn" );
#   foreach my $k (keys(%$tags)) {
#     print "$k - ",$tags->{ $k },"\n";
#   }
}

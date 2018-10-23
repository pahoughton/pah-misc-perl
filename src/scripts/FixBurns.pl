#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP3::Info;

foreach my $fn (@ARGV) {
  my $tags = get_mp3tag( $fn );
  my $ymd = $tags->{ TRACKNUM };
  if( $fn =~ /(\d\d\d\d\d\d) (.*).mp3/ ) {
    $ymd = $1;
  }

#   foreach my $k (keys(%$tags)) {
#     printf( "%-10s %s\n", $k, $tags->{ $k } );
#   }
  my $ntitle = $ymd." ".$tags->{ TITLE };
  print "mp3info2 -t \"$ntitle\" -n $ymd \"$fn\"\n";
  
}
  

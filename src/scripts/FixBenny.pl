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
  my $fnTrk = undef;
  my $fnTitle = undef;
  if( $fn =~ /(\d\d)(\d\d\d\d\d\d) (\d\d\d\d) (.*).mp3/ ) {
    $ymd = $2;
    $fnTrk = $3;
    $fnTitle = $4;
  }

  if( ! defined( $ymd ) || ! defined( $fnTrk ) || ! defined( $fnTitle ) ) {
    die "Filename parse: $fn";
  }
  
#   foreach my $k (keys(%$tags)) {
#     printf( "%-10s %s\n", $k, $tags->{ $k } );
#   }
  my $otitle = $tags->{ TITLE };
  my $ntitle = $otitle;
  $ntitle =~ s/\d\d(\d\d\d\d\d\d) \d\d\d\d (.*)/$1 $2/;
  print "mp3info2 -t \"$ntitle\" -n $fnTrk -c \"$otitle\" \"$fn\"\n";
  print "mv \"$fn\" \"$ntitle.mp3\"\n";
  
}
  

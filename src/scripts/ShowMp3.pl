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

#   foreach my $k (keys(%$tags)) {
#     printf( "%-10s %s\n", $k, $tags->{ $k } );
#   }
  my $month = undef;
  my $date = undef;
  my $yr = undef;
  my $epis = undef;
  if( $tags->{ ALBUM } =~ /(\d\d)\/(\d+)\/(\d\d), episode (\d+)/ ) {
    $month = $1;
    $date = $2;
    $yr = "19$3";
    $epis = $4;
  } else {
    print "$fn\n\t",$tags->{ ALBUM },"\n";
    exit 1;
  }
  my $title = sprintf( "%04d%02d%02d %04d %s",
		       $yr, $month, $date, $epis, $tags->{ TITLE } );
  print "$fn\n\t$title\n";
  my $nfn = "Jack Benny/The Jack Benny Show/$title.mp3";
  if( -f $nfn ) {
    die "Exists: $nfn\n$fn\n";
  }
  my @command = ("mp3info2","-t","$title","-l","The Jack Benny Show",
		 "-a","Jack Benny","-g", "OTR Comedy","-n",$epis,$fn );
  print join('" "',@command),"\"","\n";
  if( system( @command ) == 0 ) {
    rename( $fn, $nfn ) || die "ren $nfn";
  }
  
}
  

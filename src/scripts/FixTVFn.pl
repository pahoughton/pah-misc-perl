#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP4::File;
use MP4::Info;

foreach my $fn (@ARGV) {
  open( OUT, "mp4info \"$fn\" |" ) || die "open";
  my $ep = undef;
  my $sn = undef;
  my $nm = undef;
  my $sw = undef;
  while( <OUT> ) {
    if( /TV Episode: (\d+)/ ) {
      $ep = $1;
    } elsif ( /TV Season: (\d+)/ ) {
      $sn = $1;
    } elsif ( /^ Name: (.*)/ ) {
      $nm = $1;
    } elsif ( /^ TV Show: (.*)/ ) {
      $sw = $1;
    }
  }
  close( OUT );
  print "$sw $sn $ep $nm\n";

  if( defined( $ep ) && defined( $sn)
    && defined( $nm ) && defined( $sw ) ) {
    my $newFn = sprintf( "$sw.S%02dE%04d.$nm.mp4", $sn, $ep );
    $newFn =~ s/ /./g;
    if( ! -f $newFn ) {
      print "$fn $newFn\n";
      rename( $fn, $newFn ) || die "rename";
    }
  }
}

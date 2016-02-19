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
  my $nm = undef;
  my $yr = undef;
  while( <OUT> ) {
    if ( /^ Name: (.*)/ ) {
      $nm = $1;
    } elsif ( /^ Release Date: (\d\d\d\d)-/ ) {
      $yr = $1;
    }
  }
  close( OUT );
  print "$nm $yr\n";

  if( defined( $nm ) && defined( $yr ) ) {
    my $newFn = sprintf( "$nm.(%04d).mp4", $yr );
    $newFn =~ s/ /./g;
    if( ! -f $newFn ) {
      print "$fn $newFn\n";
      rename( $fn, $newFn ) || die "rename";
    }
  }
}

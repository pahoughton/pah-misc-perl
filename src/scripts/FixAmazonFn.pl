#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;

sub wanted {
  if( -f && /(\d\d) - (.*.mp3)$/ ) {
    my $nfn = "$1 $2";
    print "$_\n$nfn\n";
    if( ! -f $nfn ) {
      rename( $_, $nfn ) || die ("ren $nfn");
    }
  }
}

find( \&wanted, "." );

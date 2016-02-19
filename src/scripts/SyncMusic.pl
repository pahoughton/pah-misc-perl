#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use File::Basename;
use File::Find;


while( <> ) {
  if( /^\d/ || /^---/ || /DS_Store/ ) {
    next;
  }
  if( /^< (.*)/ ) {
    my $f = $1;
    print "#  $1\n";
  } elsif( /^> (.*)/ ) {
    my $f = $1;
    if( /.mp4/ ) {
      print "*** DUP *** $f\n";
    } else {
      print "rm \"$1\"\n";
    }
  } else {
    die "$_\n";
  }
}

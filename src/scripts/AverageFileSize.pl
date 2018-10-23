#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use Number::Bytes::Human qw(format_bytes);

our @Sizes;
sub wanted {
  if( -f $_ ) {
    my $size = (-s $_);
    if( /.jpg$/ || /.png/ || /DS_Store/ || $size < 1000000 ) {
      if( !( /.jpg$/ || /.png/ || /DS_Store/ ) ) {
	print "skippng $_\n";
      }
    } else {
      push( @Sizes, $size );
    }
  }
}

find( \&wanted, "." );

my $total;
my $cnt = @Sizes;

foreach my $s (@Sizes) {
  $total += $s;
}

print "Average is: ",format_bytes( $total / $cnt )," for $cnt files\n";

use strict;
use File::Find;
use File::Basename;
use Imager;

my %Dirs;
sub wanted {
  if( /(.jpg|.png)$/ ) {
    my $ext = $1;
    my $fn = $File::Find::name;
    my $dir = dirname( $fn );
    my $img = Imager->new();
    if( ! $img->read(file=>$fn) ) {
      print "OPEN FAILED: $fn $!\n";
      return;
    }
    my $x = $img->getwidth();
    my $y = $img->getheight();

    my $newFn = "$dir/AlbumArt-${x}x$y$ext";
    if( ! $Dirs{ $dir } ) {
      $Dirs{ $dir } = $fn;
      if( ! -f $newFn && $fn ne $newFn ) {
	if( ! rename( $fn, $newFn ) ) {
	  print "FAILED: rename( $fn, $newFn ) - $!\n";
	}
	# print "OLD: $fn\nNEW: $newFn\n";
      } else {
	if( $fn ne $newFn ) {
	  print "Exist: $fn\n   $newFn\n";
	}
      }
    } else {
      print "Have:   ",$Dirs{ $dir },"\nExtra: $newFn\n"
    }
  }
}

my $topdir = "/home/paul/SharedMusic/Library";
if( -d $topdir ) {
  find( \&wanted, $topdir );
} else {
  print "NOT DIR: $topdir\n";
}

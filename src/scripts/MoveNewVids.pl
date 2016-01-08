#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use File::Basename;
use File::Find;


sub found {
  if( -f $_ && ! /.DS_Store/ ) {
    my $destFn = $File::Find::name;
    $destFn =~ s~/Public/Music/New~/Public/Music~;

    my $alb_dir = dirname( $destFn );
    my $art_dir = dirname( $alb_dir );

    if( -e $destFn ) {
      die "Exists: $destFn\n";
    }
    if( ! -d $art_dir ) {
      mkdir( $art_dir ) || die $art_dir;
    }
    if( ! -d $alb_dir ) {
      mkdir( $alb_dir ) || die $alb_dir;
    }
    rename( $File::Find::name, $destFn ) || die "rename $destFn\n";
  }
}

find( \&found, "/Public/Music/New/Videos" );

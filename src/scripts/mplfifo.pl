use IO::Handle;

open( MPLR, ">> /home/paul/.mplayer/input-fifo" )
  || die "open fifo";

MPLR->autoflush( 1 );
print MPLR "get_file_name\n";
close( MPLR );
open( MPLR, "< /home/paul/.mplayer/input-fifo" )
  || die "open fifo";
my $buf;
print "reading\n";
read( MPLR, $buf, 100 );
print "$buf\n";


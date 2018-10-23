use IO::Handle;

STDOUT->autoflush(1);


my $disp_fn = undef;
my $is_vid = 0;
my $now_playing = undef;
while( <> ) {
    
  if( /^Playing \/home\/paul\/SharedMusic\/Library\/(.*)/ ) {
    $disp_fn = $1;
    $fullpath = "/home/paul/SharedMusic/Library/$disp_fn";
    
    $now_playing = "Song: $disp_fn";
  } elsif( /^Playing \/home\/paul\/SharedVideo\/Music Videos\/(.*)/ ) {
    $disp_fn = $1;
    $fullpath = "/home/paul/SharedVideo/Music Videos/$disp_fn";
    $now_playing = "Video: $disp_fn"
  } elsif( /ANS_TIME_POSITION=(\d+.\d+)/ ) {
    my $pos = $1;
    printf( "    pos:%4.3f\r", $pos );
  } elsif( /^Increasing filtered/ ) {
    ; # just ignore
  } elsif( /Starting playback/ ) {
    print "\n\n-- $now_playing\n";
  } else {
    print "                                                     \r";
    chop;
    print "$_\n";
  }
}

print "\n\n";

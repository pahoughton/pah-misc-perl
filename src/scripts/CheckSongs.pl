use DBI;
use MP3::Tag;
use MP4::Info;
# use Ogg::Vorbis::Header;
use strict;

my $mdb = DBI->connect("dbi:mysql:music:cview",'paul','mysql');

my $sql = "select artist, album, title, track, year, genre, filepath
from tracks
where is_music_video is null
order by artist, album, track
";

my $sth = $mdb->prepare( $sql );
$sth->execute() || die( $sql );
while( my ($artist, $album, $title, $track, $year, $genre, $filepath )
       = $sth->fetchrow_array() ) {

  my $fn = $filepath;
  $fn =~ s~/home/paul/SharedMusic/Library/~~;

  my $m4tags = get_mp4tag( $filepath );

  if( defined( %$m4tags ) ) {
    my @diffs = ();
    my $fix;
    if( $m4tags->{ NAM } ne $title ) {
      push( @diffs, "NAM" );
      $fix->{ NAM } = $title;
    }

    if( $m4tags->{ ART } ne $artist ) {
      push( @diffs, "ART" );
      $fix->{ ART } = $artist;
    }

    if( $m4tags->{ ALB } ne $album ) {
      push( @diffs, "ALB" );
      $fix->{ ALB } = $album;
    }

    {
      my $trk = $m4tags->{ TRKN }->[0];
      if( $trk =~ /(\d+)\/\d+/ ) {
	$trk = $1;
      }
      if( $trk != $track ) {
	print join(",",@{$m4tags->{ TRKN }} ), "\n";
	push( @diffs, "TRKN" );
	print " TRK: $trk <> $track\n";
	$fix->{ TRKN } = $track;
      }
    }

    if( $m4tags->{ DAY } ne $year ) {
      push( @diffs, "DAY" );
      $fix->{ DAY } = $year;
    }

    if( $m4tags->{ GNRE } ne $genre ) {
      push( @diffs, "GNRE" );
      $fix->{ GNRE } = $genre;
    }

    if( ! $m4tags->{ COVR } ) {
      push( @diffs, "COVR" );
    }

    if( $#diffs > 0 ) {
      print "$fn\n";
      foreach my $t (@diffs) {
	if( $t eq "COVR" ) {
	  print "  NO COVER\n";
	} else {
	  print "  $t: ",$m4tags->{ $t }, " <> ", $fix->{ $t },"\n";
	}
      }
    }
  } else {
    my $mp3 = MP3::Tag->new( $filepath );
    if( $mp3 ) {
      my @diffs = ();
      my $fix;
      my $was;
      $mp3->get_tags();
      my $id3v1 = $mp3->{ ID3v1 };
      if( exists $mp3->{ ID3v2 } ) {
	my $id3v2 = $mp3->{ ID3v2 };
	if( $id3v2->title() ne $title ) {
	  push( @diffs, "TIT2" );
	  $was->{ TIT2 } = $id3v2->title();
	  $fix->{ TIT2 } = $title;
	}
	if( $id3v2->year() ne $year ) {
	  push( @diffs, "TYER" );
	  $was->{ TYER } = $id3v2->year();
	  $fix->{ TYER } = $year;
	}
	{
	  my $trk = $id3v2->track();

	  if( $trk =~ /(\d+)\/\d+/ ) {
	    $trk = $1;
	  }
	  if( $trk != $track ) {
	    push( @diffs, "TRCK" );
	    $was->{ TRCK } = $trk;
	    $fix->{ TRCK } = $track;
	  }
	}
	if( $id3v2->artist() ne $artist ) {
	  push( @diffs, "TPE1" );
	  $was->{ TPE1 } = $id3v2->artist();
	  $fix->{ TPE1 } = $artist;
	}
	if( $id3v2->album() ne $album ) {
	  push( @diffs, "TCON" );
	  $was->{ TCON } = $id3v2->album();
	  $fix->{ TCON } = $album;
	}

	if( 0 ) {
	  my @cvr = $id3v2->get_frame( "APIC" );
	  if(! @cvr ) {
	    push( @diffs, "COVR" );
	  }
	}
	if( 0 ) {
	if ( exists $mp3->{ ID3v1 } ) {
	  if ( $id3v2->title() ne $id3v1->title ) {
	    push( @diffs, "tit2" );
	    $was->{ tit2 } = $id3v2->title();
	    $fix->{ tit2 } = $id3v1->title;
	  }
	  if ( $id3v2->year() ne $id3v1->year ) {
	    push( @diffs, "tyer" );
	    $was->{ tyer } = $id3v2->year();
	    $fix->{ tyer } = $id3v1->year;
	  }
	  {
	    my $trk = $id3v2->track();

	    if ( $trk =~ /(\d+)\/\d+/ ) {
	      $trk = $1;
	    }
	    my $v1trk = $id3v1->track;
	    if ( $v1trk =~ /(\d+)\/\d+/ ) {
	      $v1trk = $1;
	    }
	
	    if ( $trk != $v1trk ) {
	      push( @diffs, "trck" );
	      $was->{ trck } = $trk;
	      $fix->{ trck } = $v1trk;
	    }
	  }
	  if ( $id3v2->artist() ne $id3v1->artist ) {
	    push( @diffs, "tpe1" );
	    $was->{ tpe1 } = $id3v2->artist();
	    $fix->{ tpe1 } = $id3v1->artist;
	  }
	  if ( $id3v2->album() ne $id3v1->album ) {
	    push( @diffs, "tcon" );
	    $was->{ tcon } = $id3v2->album();
	    $fix->{ tcon } = $id3v1->album;
	  }
	} }
	  
	if( $#diffs > 0 ) {
	  print "$fn\n";
	  foreach my $t (@diffs) {
	    if( $t eq "COVR" ) {
	      print "  NO COVER\n";
	    } else {
	      print "  $t: ",$was->{ $t }, " <> ", $fix->{ $t },"\n";
	    }
	  }
	}
	
      } else {
	print "$fn\n  NO mp3v2\n";
      }
    } else {
      print "$fn\n   UNSPPORTED\n";
    }
  }
}


#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;

use DBI;
use File::Basename;
use Audio::DB::Parse::ReadFiles;
use Audio::DB::Schema;
use Audio::DB;
use Term::ReadLine;


my $adb = Audio::DB->new( -adaptor => "dbi::mysql",
			  -user    => "paul",
			  -pass    => "mysql",
			  -dsn     => "music" );
my $mdb = $adb->adaptor()->dbh();

while( <> ) {
  if( /.\/(.*)\/(.*)\/[0-9-]+ (.*).mp4/ ) {
    chop;
    my $artist = $1;
    my $album = $2;
    my $song = $3;
    #print "$artist, $album, $song\n";
    my $sql = "select genre, album_artist, artist, track, year from tracks
where title = \"$song\" and artist = \"$artist\" and album = \"$album\"";

    my $sth = $mdb->prepare( $sql );
    $sth->execute() || die( $sql );
    my ($g,$aa,$a,$t,$y) = $sth->fetchrow_array();
    if( $g ) {
      my $ainfo;
      if( $aa ne $a ) {
	$ainfo = "-R \"$aa\" -a \"$a\"";
      } else {
	$ainfo = "-a \"$a\"";
      }
      print "mp4tags -s \"$song\" -A \"$album\" $ainfo -y $y -t $t -g \"$g\" \"$_\"\n";
    } else {
      print "# NOT FOUND: $_\n";
    }
  } else {
    print "# ERROR: $_\n";
  }
}

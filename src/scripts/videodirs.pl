use MP3::Info;
use File::Basename 'dirname','basename'; # Lincoln's recursive approach
use File::Find;      # For recursing into directories via my method...
use LWP::MediaTypes; # NOT YET IN USE
use DBI;
use strict;

our $Count = 0;
my %MissingTags;
my %Mp3Genres;
foreach my $g (@MP3::Info::mp3_genres) {
  $Mp3Genres{ $g } = 1;
}

my $db = DBI->connect("dbi:mysql:itunes",'paul','mysql');

sub wanted {
  if( -f $_ ) {
    my $fn = basename( $File::Find::name );

    if( $fn =~ /^([^\-]+) - (.*)(.mpg|.flv)/ ) {
      my $f_artist = $1;
      my $f_title = $2;
      my $f_ext = $3;

      my $q_title = $f_title;
      my $q_artist = $f_artist;

      $q_title =~ s/^([A-Za-z0-9 ]+)[^A-Za-z0-9 ].*/$1/;
      $q_title =~ s/\s*$//;
      $q_title =~ s/'/\\'/g;
      $q_artist =~ s/'/\\'/g;
      my $sql = "
select artist, album, track, title
from songs_view
where artist like '$f_artist%'
and title like '$q_title%'
";
      my $sth = $db->prepare( $sql );
      $sth->execute() || print $sql;
      my ($artist, $album, $track, $title) = $sth->fetchrow_array();

      if( defined( $artist ) && defined( $title ) ) {
	$title =~ s/-lowres//;
	my $adir = dirname( $File::Find::name );
	my $fn = sprintf( "%02d $title$f_ext",$track );
	$album =~ s/^\./_/;
	print "    $artist/$album/$fn\n";
	my $dest_name = "/home/paul/SharedVideo/NewMV/$artist/$album/$fn";
	++ $Count;
	mkdir( "/home/paul/SharedVideo/NewMV/$artist" );
	mkdir( "/home/paul/SharedVideo/NewMV/$artist/$album" );
	rename( $File::Find::name, $dest_name )
	   || print "RENAME: $!\n  f: '",$File::Find::name,
	     "'\n  t: '",$dest_name,"'\n";
      } else {
	print "NOT FOUND: A:'$q_artist' T:'$q_title'\n";
      }
    } else {
      print "NO MATCH: $_\n";
    }
  }
}

find( \&wanted,
      "/home/paul/SharedVideo/Music Videos");

print "Count: $Count\n";




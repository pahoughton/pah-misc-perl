use DBI;
use strict;

my $mdb = DBI->connect("dbi:mysql:music:cview",'paul','mysql');

my $base = "/home/paul/SharedMusic/Library/";

my $aid = 1029;
my $dir = "$base/Tyra B_/Singles";

my $l_sql = "select album_dir, cover_art_file
from albums
where album_id = $aid
";

my $t_sql = "select song_id, filepath from songs where album_id = $aid";

my @Updates;

my $l_sth = $mdb->prepare( $l_sql );
$l_sth->execute() || die( $l_sql );
my $album_dir;
while( my ($a_dir, $cover_art_file )
       = $l_sth->fetchrow_array() ) {
  $album_dir = $a_dir;
  my $n_ca_fn = $cover_art_file;
  $n_ca_fn =~ s~$album_dir~$dir~;
  my $updt = "update albums set
album_dir = \"$dir\",
cover_art_file = \"$n_ca_fn\"
where album_id = $aid
";
  push( @Updates, $updt );
}

my $t_sth = $mdb->prepare( $t_sql );
$t_sth->execute() || die( $t_sql );
while( my ($sid, $fp) = $t_sth->fetchrow_array() ) {
  my $nfp = $fp;
  $nfp =~ s~$album_dir~$dir~;
  my $updt = "update songs set
filepath = \"$nfp\"
where song_id = $sid
";
  print "$album_dir\n$dir\n$fp\n$nfp\n";
  push( @Updates, $updt );
}

foreach my $u (@Updates) {
  print $u,"\n";
  $mdb->do( $u ) || die( "ERROR" );
}

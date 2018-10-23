use File::Basename;
use File::Find;
use DBI;
use MP3::Info;

our $VideoFiles;
sub wanted {
  if( -f $_ ) {
    my ($fn,$dir,$ext) = fileparse( $File::Find::name, ('-lowres.mpg','.mpg') );
    # print $fn,"\n";
    if( $fn =~ /(.*) - (.*)/ ) {
      $VideoFiles->{ $1 }->{ $2 } = $File::Find::name;
      my $tag = get_mp3tag($file) or die "No TAG info";
      while( my ($k, $v ) = each( %{ get 
      # print "'$1' '$2'\n";
    }
  }
}

find( \&wanted, "/home/paul/SharedVideo/Music Videos" );




use Mac::iTunes::Library::XML;
use URI;
use URI::Escape;

my $library = Mac::iTunes::Library::XML->parse( 'iTunes Music Library.xml' );

my %items = $library->items();

while( my ($ik, $iv) = each( %items ) ) {
  print "$ik\n";
  while( my ($ak,@av) = each( %$iv ) )  {
    print "   $ak\n";
    my $a_num = 0;
    foreach my $b (@av) {
      print "    $a_num:";
      ++ $a_num;
      my $b_num = 0;
      foreach my $c (@$b) {
	print "$b_num: ",$c->persistentID(),"\n";
	my $uri = URI->new( $c->location() );
	
	print "    ",uri_unescape( $uri->path() ),"\n";
	++ $b_num;
      }
    }
  }
}

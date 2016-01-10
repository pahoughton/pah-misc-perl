my @splits;

while( <> ) {
  if( /(\d+\.\d+)\s+(\d+\.\d+)\s+/ ) {
    my $a = $1;
    my $b = $2;

    $a += 0.1;
    $b -= 0.1;

    my $a_min;
    my $a_sec;
    my $b_min;
    my $b_sec;
    $a_min = int(int($a)/60);
    $a_sec = $a - ($a_min*60);
    $b_min = int(int($b)/60);
    $b_sec = $b - ($b_min*60);

    my $ms;
    $ms = sprintf( "%d.%.02f",$a_min,$a_sec );
    push( @splits, $ms );
    $ms = sprintf( "%d.%.02f",$b_min,$b_sec );
    push( @splits, $ms );
  }
}
print join( ' ', @splits),"\n";

    
      

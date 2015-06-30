# path2nospacedir.pl - 2014-03-01 14:14
#
# Copyright (c) 2014 Paul Houghton <paul4hough@gmail.com>
#
use File::Basename;

my $num = 1;
while( <> ) {
    if( /^[[:ascii:]]+$/ ) {
	chop;
	my $ext = $_;
	$ext =~ s/.*\.(.+)$/$1/;
	my $origfn = $_;
	s/'/'\\''/g;
	my $nfn = sprintf( "%08d.$ext",$num++ );
	if( -e "$nfn" ) {
	    die "exists $nfn";
	}
	print "mv -i ../'";print; print "' $nfn\n" ;
    }
}

## Local Variables:
## mode:perl
## end:

package Text::CommaNum;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::CommaNum ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';


# Preloaded methods go here.

sub CommaNum( $ );

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Text::CommaNum - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Text::CommaNum;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Text::CommaNum, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 SEE ALSO

L<perl>.

=cut

sub CommaNum ( $ ) {
  my( $num ) = (@_);

  my $whole = undef;
  my $decimal = undef;

  ($whole, $decimal ) = split( /\./,$num );

  my $len = length( $whole );

  my $out;
  {
    if( $len > 3 )  {
      my $in = $whole;
      my $l = $len % 3;
      if( $l ) {
	$out = substr( $in, 0, $l ).",";
	$in = substr( $in, $l );
	$l = $len - $l;
      } else {
	$l = $len;
      }
      while( $l > 3 ) {
	$out .= substr( $in, 0, 3 ).",";
	$in = substr( $in, 3 );
	$l -= 3;
      }
      $out .= $in;
      if( $decimal ) {
	$out .= ".$decimal";
      }
    } else {
      $out = $num;
    }
  }
  #print "$num   w: $whole  o: $out\n";

  return( $out );
}


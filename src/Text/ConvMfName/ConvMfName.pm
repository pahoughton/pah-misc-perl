package Text::ConvMfName;

use 5.006;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::ConvMfName ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  ConvMfName
);
our $VERSION = '1.01';

our $FILLER_COUNT = 0;

# Preloaded methods go here.

sub ConvMfName (@); #

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Text::ConvMfName - Convert main frame field names to mixed case

=head1 SYNOPSIS

  use Text::ConvMfName;

  my $fldName = ConvMfName( "TRS-PREFIX-NET-USAGE", "TRS-PREFIX" );

  print "$fldName\n"; # will output netUsage

=head1 DESCRIPTION

Convert a dash '-' seperated name to mix case stripping the specified
prefix characters.

=head2 EXPORT

ConvMfName


=head1 AUTHOR

Paul Houghton <paul4hough@gmail.com>

=head1 SEE ALSO

L<perl>.

=cut


sub ConvMfName (@) {
  my ($mfName, $strip) = (@_);

  my $name;

  if( $strip ) {
    $mfName =~ s/^$strip//;
  }

  if( $mfName =~ /FILLER/ ) {
    $name = sprintf( "filler_%02d", $FILLER_COUNT );
    ++ $FILLER_COUNT;
  } else {

    foreach my $namePart (split( /-/, $mfName )) {

      $namePart =~ tr/A-Z/a-z/;

      if( $FixWords{ $namePart } ) {
	$namePart = $FixWords{ $namePart };
      }

      substr( $namePart, 0, 1 ) =~ tr/a-z/A-Z/;

      $name .= $namePart;
    }
  }

  substr( $name, 0, 1 ) =~ tr/A-Z/a-z/;

  return $name;
}

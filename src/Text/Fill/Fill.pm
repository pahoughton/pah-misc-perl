#
# File:	    Fill.pm
# Project:  PerlUtils %PP%
# Item:	    %PI% (%PF%)
# Desc:
#
#   Source for Text::Fill perl module.
#
# Notes:
#
#   See pod below for documentation
#
# Created:  02/25/01 00:19
# Author:   Paul Houghton <paul.houghton@wcom.com>
#
# Revision Information (See Revision Log below for more info)
#
#   Last Mod By:    %PO%
#   Last Mod:	    %PRT%
#   Version:	    %PIV%
#   Status:	    %PS%
#
# %PID%
#


package Text::Fill;
require 5.6.0;
use strict;
use warnings;
our $VERSION = "1.01";
require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::Fill ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( &fill
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

# Preloaded methods go here.

our $debug = 0;

sub fill ( $$$@ );


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You better edit it!

# POD HERE

=head1 NAME

Test::Fill - Fill and wrap mutilple paragraphs

=head1 SYNOPSIS

    Use::Text::Fill( fill );

    my $text = fill( 4, 4, 75, @paragraphs );
    print $text;

=head1 DESCRIPTION

    The fill function reformats text multiple text paragraphs according
    to the arguments given. Eah paragraph is separated by a pair of
    newlines with only spaces between them (i.e. \n\s*\n). The
    text of each paragraph will be indented the number of spaces
    specifed by the `$first', and `$rest' options. Each line will
    be broken up so that it is no longer than `$width'.

    Any paragraph in a single call that is indented more that the
    rest of the paragraphs passed is not wrapped. So, if you had
    a sequence of descriptive text paragraphs then an indented
    piece of example code, the exaple code would be indented with
    `$first' and the abount of original indent, but it's lines
    would not be wrapped or filled.

    Any words that are to long to be wrapped will start on a
    new line, but otherwise be untouched.

=head1 FUNCTIONS

=over 4

=item Text::fill( $first, $rest, $width, @paragraphs )

=over 4

=item Aguments:

=over 4

=item first (number)

number of characters to indent the first line of each paragraph.

=item rest (number)

number of characters to indent the rest of the of each paragraph.

=item width (number)

the maximum width of each line including the indent.

=item paragraphs (array of string)

The text of the paragraphs. The array is is is first `join'ed with a
single space, so the seperate elements in it has no significance.

=back

=item Returns:

the formated paragraphs are returned as a single scalar text string.

=back

=back

=head1 EXAMPLE

Here is an example of the effect of the fill function:

    $paras = "
Here are a couple of paragraphs to fill and wrap with
the Text::Fill::fill() function.
each paragraph is separated by a '\n\s*\n' sequence and special
code sections that are indented as compared to the
rest of the text are not wrapped. Here is a non wrapped snippet:

    my $var;
    foreach $var (split(/\s/,"these are words to use" )) {
      print "$var";
    }";


    use Text::Fill;
    my $text = fill( 8, 8, 75, $paras );
    print $text;

This is what you would get output:

        Here are a couple of paragraphs to fill and wrap with the
        Text::Fill::fill() function. each paragraph is separated by a
        `\n\s*\n' sequence and special code sections that are indented as
        compared to the rest of the text are not wrapped. Here is a non
        wrapped snippet:

            my $var;
            foreach $var (split(/s/,"these are words to use" )) {
              print "$var";
            }

=head1 AUTHORS

%PRT%

Paul Houghton <paul.houghton@wcom.com>

=head1 SEE ALSO

L<Text::Tabs>
L<Text::Wrap>

perl(1).

=cut

use Text::Tabs qw(expand unexpand);
use App::Debug;

sub fill ( $$$@ ) {
  my ($firstIndent,
      $restIndent,
      $width,
      @t) = @_;

  my $text = expand(join(" ",@t));

  Debug( 5, "TEXT: $text\n" );
  my @doc = split( /\n\s*\n/, $text );

  my $maxWidth = $width;
  my $firstPad;
  my $restPad;

  if( $firstIndent ) {
    $firstPad = sprintf( "%*s", $firstIndent, " " );
  } else {
    $firstPad = "";
  }

  if ( $restIndent ) {
    $restPad = sprintf( "%*s", $restIndent, " " );
  } else {
    $restPad = "";
  }

  # print "F: $firstIndent '$firstPad'\nR: $restIndent '$restPad'\n";
  $restPad = sprintf( "%*s", $restIndent, " " );
  my $outText;

  my $initOffset = "";
  my $paraCount = 0;
  my $para;
  foreach $para (@doc) {
    #print "FILL: $para\n";
    if( $para =~ /^(\s*)\S/ ) {
      my $offset = $1;
      if( $paraCount && $initOffset ) {
	if( length( $offset ) > length( $initOffset ) ) {
	  my $line;
	  foreach $line (split(/\n/,$para)) {
	    $outText .= $firstPad . $line . "\n";
	  }
	  $outText .= "\n";
	  next;
	}
      } else {
	if( $paraCount ) {
	  if( length( $offset ) ) {
	    my $line;
	    foreach $line (split(/\n/,$para)) {
	      $outText .= $firstPad . $line . "\n";
	    }
	    $outText .= "\n";
	    next;
	  }
	} else {
	  ++ $paraCount;
	  $initOffset = $offset;
	}
      }
    } else {
      next;
    }

    $para =~ s/^\s+//;
    $para =~ s/\s+$//;
    $para =~ s/\s+/ /g;

    Debug( 5, "P:\n'$para'\n\n" );

    if ( $para ) {
      my $width = $maxWidth - $firstIndent;

      if ( $para =~ s/^(.{0,$width})(\s|\Z)//xm) {
	$outText .= $firstPad . $1 . "\n";
      } else {
	my $tmp;
	($tmp) = $para =~ s/^(\S+)//;
	$outText .= $firstPad . $tmp . "\n";
      }

      $width = $maxWidth - $restIndent;

      while ( $para !~ /^\s*$/ ) {
	if ( $para =~ s/^(.{0,$width})(\s|\Z)//xm) {
	  $outText .= $restPad . $1 . "\n";
	} else {
	  my $tmp;
	  ($tmp) = $para =~ s/^(\S+)//;
	  $outText .= $restPad . $tmp . "\n";
	}
      }

      $outText .= "\n";
    }
  }

  return( $outText );
}


#
# Revision Log:
#
# Note: Also Check the ChangeLog in this directory.
#
# %PL%
#

# Set XEmacs mode
#
# Local Variables:
# mode:perl
# End:

#!/usr/local/bin/perl
#
# Title:        MmRecipesToSingleFile.pl
# Project:	Cooking
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	04/21/02 07:03
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

my %Mesure = ( tb   => "tablespoon",
	       ts   => "teaspoon",
	       T    => "tablespoon",
	       t    => "teaspoon",
	       lg   => "large",
	       c    => "cup",
	       ea   => "each",
	       oz   => "ounce",
	       lb   => "pound"
	       
	     );

sub WriteRecipe {
  my ($title,$recipe) = (@_);

  my $fn = $title;
  $fn =~ s/w\//with/g;
  $fn =~ s/W\//with/g;
  $fn =~ s/\// /g;

  if( -f "split/$fn.txt" && ! $Files{ $fn } ) {
    $Files{ $fn } = 1;
    while( 1 ) {
      $dup = sprintf( "DUP.%03d",$Files{ $fn } );
      if( -f "split/$fn.$dup.txt" ) {
	$Files{ $fn } ++;
      } else {
	last;
      }
    }
  }
  if( $Files{ $fn } ) {
    $dup = sprintf( "DUP.%03d",$Files{ $fn } );
    $fn .= ".$dup";!
    $Files{ $fn } ++;
    
  } else {
    $Files{ $fn } = 1;
    $dup = "       ";
  }
  print "$dup $title ****\n";
  open( OUT, "> split/$fn.txt" ) || die "open 'split/$fn.txt' - $!";
#  foreach $ln (split(/\n/,$recipe)) {
#    print "LINE: $ln\n";
#  }
  print OUT $recipe;
  close( OUT );
}

while( <> ) {

  if( /^MMMMM--/ ) {
    my $recipe;
    $recipe = $_;
    my $title = "";
    while( <> ) {
      if( /^MMMMM$/ ) {
	# end
	$recipe .= $_;
	if( $title ) {
#	  print "$title *******\n$recipe\n";
	  WriteRecipe( $title, $recipe );
	  last;
	} else {
	  die "Title not found for\n$recipe\n" ;
	}
      } elsif ( /^\s+Title: (.*)/ ) {
	$title = $1;
      }
      $recipe .= $_;
    }
  } elsif( /^-------/ ) {
    my $recipe;
    $recipe = $_;
    my $title = "";
    while( <> ) {
      if( /^-----$/ ) {
	# end
	$recipe .= $_;
	if( $title ) {
	  WriteRecipe( $title, $recipe );
	  # print "$title ****\n$recipe\n";
	  last;
	} else {
	  die "Title not found for\n$recipe\n" ;
	}
      } elsif ( /^\s+Title: (.*)/ ) {
	$title = $1;
      }
      $recipe .= $_;
    }
  } elsif ( /^\s*$/ ) {
    # skip blank
  } else {
    print "ERROR: unprocessed line:\n$_";
  }
}
      
    

#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

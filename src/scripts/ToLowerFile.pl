#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            ToLowerFile.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    10/19/96 02:46
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1996/11/14 23:15:40  houghton
# Initial Version.
#
# 

if( $#ARGV < 0 )
{
  print "Need pattern & file names\n";
  exit( 1 );
}

print "$ARGV[0]\n";

sub lowerit
  {
#    my ($tmp) = @_;
#    $tmp =~ tr/A-Z/a-z/;
#    $tmp;
    print @_;
    print "\n";
  }
    
for( $a = 1; $a < $#ARGV; $a++ )
{
  open( IN, "<$ARGV[$a]" );
  $outfn = $ARGV[$a];
  $outfn =~ s/Rogue/rogue/;

  print "Writing $outfn\n";
  open( OUT, ">$outfn" );

  while(<IN>)
    {
      if( /$ARGV[0]/ )
	{
	  $line = $_;
	  $line =~ s/($ARGV[0])/lc $1;/eg;
	  print OUT "$line";
	}
      else
	{
	  print OUT $_;
	}
	
    }
  close IN;
  close OUT;
}



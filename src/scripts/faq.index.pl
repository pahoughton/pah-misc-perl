#!/usr/local/bin/perl
#
# Title:        faq.index.pl
# Project:	News
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	08/05/97 16:25
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

use File::Find;

open( OUT, "> /tmp/faq.index.$$" ) ||
  die "open > /tmp/faq.index.$$ - $!";
  
sub FaqFile {
  $fn = $_;
  $counter ++;

  if( ($counter % 100) == 0 ) { print STDERR "."; }
  
  if( -f $_ ) {
    if( /.gz$/ ) {
      open( FAQ, "zcat $_ |" ) || die "zcat $_ | $!";
    } else {
      open( FAQ, "< $_" ) || die "open < $_ $!";
    }

    while(<FAQ>)
      {
	if( /Subject: +(.*)$/ )
	  {
	    $sub = $1;
	    # $dir = substr( $File::Find::dir, 1 );

	    print OUT "{$sub}$File::Find::dir/$fn\n";
	    last;
	  }
      }
    close( FAQ );
  }
}

find( \&FaqFile, "news.answers" );
close( OUT );

system( "sort /tmp/faq.index.$$ > /tmp/faq.sort.$$" ) &&
  die "runnning sort $!";

open( OUT, "> news.answers/00-Index.html" ) ||
  die "open > news.answers/00-Index.html $!";

print OUT "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML//EN\">\n";
print OUT "<html>\n";
print OUT "  <head>\n";
print OUT "    <title>Faq Index</title>\n";
print OUT "  </head>\n";
print OUT "  <body>\n";
print OUT "      <h1>Faq Index</h1>\n";
print OUT "      <UL>\n";

open( IN, "< /tmp/faq.sort.$$" ) ||
  die "open < /tmp/faq.sort.$$ $!";

while(<IN>)
  {
    if( /\{(.*)\}news.answers\/(.*)/ )
      {
	print OUT "  <LI> <A HREF=\"$2\">$1</A>\n";
      }
  }
close( IN );

print OUT "	    </UL>\n";
print OUT "  </body>\n";
print OUT "</html>\n";

close( OUT );

unlink( "/tmp/faq.index.$$" );
unlink( "/tmp/faq.sort.$$" );

#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

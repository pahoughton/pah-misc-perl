#!/usr/local/bin/perl
#
# Title:        sbbdb.pl
# Project:	Phone
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	06/15/99 08:55
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

open( IN, "< /home/houghton/bbdb.tex" ) || die;

while ( <IN> ) {
  if ( /^\\beginrecord/ ) {
    while ( <IN> ) {
      if ( /\\firstline\{([^\}]+)\}/ ) {
        $name = $1;
      }
      if ( /\\comp\{([^\}]+)\}/ ) {
          $comp = $1;
      }
      if ( /\\phone\{([^:]+): ([^\}]+)\}/ ) {
          $phone{$1} = $2;
      }
      if ( /\\email\{([^\}]+)\}/ ) {
          $email = $1;
	  $email =~ s/\$//g;
	  $email =~ s/\\-//g;
      }
      if( /\\address\{(.*)\\\\/ ) {
	push @addr, $1;
	while( <IN> ) {
	  if( /(.*)\\\\/ ) {
	    push @addr, $1;
	  }
	  if( /\\\\\}/ ) {
	    last;
	  }
	}
      }
      if( /\\note/ ) {
	if( /\\note\{creation/ || /\\note\{timestamp/ ) {
	  next;
	}
	if( /\\notes\{[Pp]ager:\s+([^\}]+)\}/ ) {
	  $phone{pager} = $1;
	}
      }
      if ( /^\\endrecord/ ) {
	if( $#ARGV >= 0 ) {
	  $match = 0;
	  foreach $arg (@ARGV) {
	    $match |= ( $name =~ /$arg/i ) ;
	    $match |= ( $comp =~ /$arg/i ) ;
	    $match |= ( $email =~ /$arg/i ) ;
	  }
	} else {
	  $match = 1;
	}
	if( $match ) {
	  print "$name $comp\n";
	  print "      email: $email\n";
	  foreach $p (keys %phone) {
	    printf( "   %8s: %s\n", $p, $phone{$p} );
	  }
	  foreach $a (@addr) {
	    print "       addr: $a\n";
	  }
	}
	@addr = ();
	$name = "";
	$comp = "";
	$email = "";
	delete @phone{ keys %phone };
	break;
      }
    }
  }
}




#
# $Log$
# Revision 1.1  1999/06/15 17:41:39  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

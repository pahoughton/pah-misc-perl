#!/usr/local/bin/perl
#
# Title:        phone.pl
# Project:	LDAP
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul A. Houghton - (paul.houghton@wcom.com)
# Created:	06/17/99 10:49
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
# 

use Net::LDAPapi;
use Getopt::Long;

%args = ();

GetOptions( \%args, "filter=s" );

$ldap_host = "cworld";
$wcom_host = "directory.wcom.com";

if (($ld = new Net::LDAPapi(-host=>$ldap_host)) == -1) {
  die "LDAP init to $ldap_host: $!";
}

if( ($ld->bind_s != LDAP_SUCCESS ) ) {
  $ld->perror( "bind_s" );
  die "bind_s: $!";
}

sub Search {
  my $key = shift(@_);
  my $filter;

  if( $key =~ /=/ ) {
    $filter = $key;
  } else {
    $filter = "cn=*$key*";
  }

  @attrs = ();

  if( $ld->search_s( "", LDAP_SCOPE_SUBTREE, $filter, \@attrs, 0 ) != LDAP_SUCCESS ) {
    $ld->perror("search_s" );
    die "search_s: $!";
  }
}

sub Show {
  my $ent;
  my $dn;
  my $val;
  my %rec;

  for( $ent = $ld->first_entry; $ent; $ent = $ld->next_entry ) {
    $dn = $ld->get_dn;
    print "DN: $dn\n";

    delete @rec{keys %rec};
    
    for( $attr = $ld->first_attribute;
	 $attr ne "";
	 $attr = $ld->next_attribute ) {
      
      if( $attr =~ /home.*phone/ ) {
	@val = $ld->get_values( $attr );
	$rec{home} = $val[0];
      }
      
      if( $attr eq telephonenumber ) {
	@val = $ld->get_values( $attr );
	$rec{work} = $val[0];
      }

      if( $attr eq facsimiletelephonenumber ) {
	@val = $ld->get_values( $attr );
	$rec{fax} = $val[0];
      }

      if( $attr eq pagertelephonenumber ) {
	@val = $ld->get_values( $attr );
	$rec{pager} = $val[0];
      }

      if( $attr eq pagerpin ) {
	@val = $ld->get_values( $attr );
	$rec{pin} = $val[0];
      }

      if( $attr eq mobiltelephonenumber ) {
	@val = $ld->get_values( $attr );
	$rec{mobil} = $val[0];
      }
      
      if( $attr eq mail ) {
	@val = $ld->get_values( $attr );
	$rec{email} = $val[0];
      }

#       print "$attr:\n";
#       foreach $val ($ld->get_values( $attr )) {
# 	print " -> '$val'\n";
#       }
    }
  
    foreach $f (keys(%rec)) {
      printf( "  %10s: %s\n", $f, $rec{$f} );
    }
    
  }
}

foreach $k (@ARGV) {
  Search( $k );
  Show();
}

$ld->unbind($ld);

      




#
# $Log$
# Revision 1.1  2003/05/18 23:46:51  houghton
# *** empty log message ***
#
#

# Local Variables:
# mode:perl
# End:

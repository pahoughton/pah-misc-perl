#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            getsp.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    5/8/94
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 14:58:11  houghton
# Initial Version.
#
# 


#$PROC		= $ARGV[0];
$SYB_DB		= $ARGV[0];
$SYB_USER	= $ARGV[1];
$SYB_PWD 	= $ARGV[2];

open(OUTF,">$SYB_DB.procs.sql");

&set_db($SYB_DB,$SYB_USER,$SYB_PWD);

&send_sql("select id, name, type from sysobjects where type in ('P','TR','V') ");

while(@pinfo = &get_record())
{
  
  print "Getting: $pinfo[1] - $pinfo[2]\n";
  
  &send_sql("select c.text ");
  &send_sql("from syscomments c ");
  &send_sql("where 	c.id = $pinfo[0] ");
  
  #
  # For each record returned 
  #
  
  
  while(@rec = &get_record())
    {
      print OUTF @rec;
    }
  
  print OUTF "\ngo\n\n";
}


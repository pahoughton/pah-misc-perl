#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            listold.pl
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
# Revision 1.1  1995/11/16 14:58:12  houghton
# Initial Version.
#
# 



$SYB_USER	= $ARGV[2];
$SYB_PWD 	= $ARGV[1];
#$SYB_DB		= $ARGV[3];

$SYNCDB 	= "sync";

$SYB_DB = "tnms";
$SYB_USER = "houghton";
$SYB_PWD = "";

&set_db($SYB_DB,$SYB_USER,$SYB_PWD);

&send_sql("select so.name, so.crdate, tnmso.crdate ");
&send_sql("from sync.dbo.sysobjects  so, tnms.dbo.sysobjects  tnmso ");
&send_sql("where 	so.type = 'U' ");
&send_sql("and		so.name != 'tcsr_syn_tbl' ");
&send_sql("and		so.name = tnmso.name ");
#&send_sql("and		so.crdate < tnmso.crdate ");
&send_sql("order by so.name ");

#
# For each record returned 
#
	 

print "$SYNCDB tables that are older than $SYB_DB tables\n\n";

while(@tableRec = &get_record())
{
  printf("%-30s %-20s %-20s\n",
	 $tableRec[0],
	 $tableRec[1],
	 $tableRec[2]);
}

#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            store_db_data.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
#
# notes / limits can't have /* more than once on a line 
#                    or in quoted strings
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
# Revision 1.1  1995/11/16 14:58:14  houghton
# Initial Version.
#
# 


$FILE_DATE		= $ARGV[0];
$FILE_DB_NAME	= $ARGV[1];
$DB_NAME		= $ARGV[2];
$DB_USER 		= $ARGV[3];
$DB_PWD			= $ARGV[4];

$BASE_DIR	= "./";

#
#	to use bpc set this to 1
#	to use insert staments set this to 0
#

$BCP = 1;

#
#	get date/time
#

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$dt = sprintf("%02d%02d%02d.%02d%02d%02d",
	$year % 100,
	$mon + 1,
	$mday,
	$hour,
	$min,
	$sec);

&set_db($DB_NAME,$DB_USER,$DB_PWD);

#
#	get tablename from db
#

&send_sql( "select o.name, u.name, o.id\n".
	  "from sysobjects o, sysusers u\n".
	  "where o.type = 'U' and u.uid = o.uid\n".
	  "order by o.name\n");



while( (@table = &get_record()) )
{
  
  #
  #	now get the column name for this table
  #
  
  $in_fn = "$BASE_DIR$FILE_DB_NAME.$table[1].$table[0].data.$FILE_DATE";
  
  #	$in_fn = $BASE_DIR . $table[0] . ".ins_data." . $FILE_DATE;
  
  print "Truncating Table $DB_NAME.$table[1].$table[0]\n";
  
  &send_sql($db2,
	    "setuser '$table[1]'\n".
	    "truncate table $table[0]\n");
  
  while(&get_record())
    {
    }
  
  if($BCP == 0)
    {
      die "BCP MODE ONLY\n";
      
    }
  else
    {
      
      print "Loading Table: Input file $in_fn\n";

      $stat = system("bcp $DB_NAME.$table[1].$table[0] in $in_fn*  -c -t \\\\t -r \\\\n -U$DB_USER -P$DB_PWD");
      
      if($stat != 0)
	{
	  print "Error during BCP of $DB_NAME.$table[1].$table[0]\n";
	}
    }
}



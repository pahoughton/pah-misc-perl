#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            printsyncdata.pl
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
# Revision 1.1  1995/11/16 14:58:13  houghton
# Initial Version.
#
# 

#
# Memdb Sybase Script Generator
#

$SYB_USER	= $ARGV[2];
$SYB_PWD 	= $ARGV[1];
$SYB_DB		= $ARGV[3];

$SYNCDB 	= "tnms";

$SYB_DB = "tnms";
$SYB_USER = "houghton";
$SYB_PWD = "";

%trigger_types = ("I","insert","U","update","D","delete");
%trigger_colname = ("I","instrig","U","updtrig","D","deltrig");
@columns = ();

&set_db($SYB_DB,$SYB_USER,$SYB_PWD);

&send_sql("select o.name ");
&send_sql("from sync.dbo.sysobjects  o ");
&send_sql("where 	o.type = 'U' ");
&send_sql("and		o.name != 'tcsr_syn_tbl' ");
&send_sql("order by o.name ");

#
# For each record returned 
#
	 

while(@tableRec = &get_record())
{

  &send_sql("select c.name, t.name, c.length ");
  &send_sql("from tnms.dbo.syscolumns c, tnms.dbo.sysobjects o, tnms.dbo.systypes t, tnms.dbo.systypes st ");
  &send_sql("where 	c.id = o.id ");
  &send_sql("and		o.name = '$tableRec[0]' ");
  &send_sql("and		c.usertype = st.usertype ");
  &send_sql("and		st.type = t.type ");
  &send_sql("and		t.type < 100 ");
  &send_sql("and		t.type != 18 ");
  
  print "\n\nTable: $tableRec[0]\n";
  
  @colName = ();
  @colLen = ();
  
  while(@colRec = &get_record())
    {
      if($colRec[2] < 5)		#len < 5
	{
	  $len = 5;
	}
      else
	{
	  $len = $colRec[2];
	}
      
      $colLen[++$#colLen] = $len;
      $colName[++$#colName] = $colRec[0];
      printf("%-${len}.${len}s  ",$colRec[0]);
    }
  
  print "\n\n";
  &send_sql("select ");
  for($c = 0; $c < $#colName; $c++)
    {
      &send_sql("$colName[$c], ");
    }
  &send_sql("$colName[$c] ");
  &send_sql("from tnms.dbo.$tableRec[0] ");
  
  while(@dataRec = &get_record())
    {
      for($c = 0; $c < $#dataRec + 1; $c++)
	{
	  printf("%-${colLen[$c]}s  ",$dataRec[$c]);
	}
      print "\n";
    }
}

#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            tabledef.pl
# 
# Description:
#
#   Memdb Sybase Script Generator
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
# Revision 1.1  1995/11/16 14:58:14  houghton
# Initial Version.
#
# 




$SYB_DB		= $ARGV[0];
$SYB_USER	= $ARGV[1];
$SYB_PWD 	= $ARGV[2];


open(OUT,">$SYB_DB.tables.sql");

&set_db($SYB_DB,$SYB_USER,$SYB_PWD);

&send_sql("select o.id, o.name from sysobjects o where type = 'U' ");

while(@table_info = &get_record())
{

  print "Getting: $table_info[1] - $table_info[0]\n";
  
  $TABLE = $table_info[1];
  
  &send_sql("select c.name, t.name, c.length ");
  &send_sql("from syscolumns c, systypes t, systypes st ");
  &send_sql("where 	c.id = $table_info[0] ");
  &send_sql("and		c.usertype = st.usertype ");
  &send_sql("and		st.type = t.type ");
  &send_sql("and		t.type < 100 ");
  &send_sql("and		t.type != 18 ");
  
#
# For each record returned 
#
	 
  @columns = ();
  
  while(@rec = &get_record())
    {
      print "$rec[0] - $rec[1] - $rec[2]\n";
      
      $columns[++$#columns] = $rec[0]; 	#add column name to array
      $colType[++$#colType] = $rec[1];	#add column type to array
      $colLen[++$#colLen] = $rec[2];		#add column len to array
    }
  
  #
  # Now the Table Create Script
  #
  

  print OUT	"use $SYB_DB\ngo\n";
  print OUT	"drop table $SYB_DB.dbo.$TABLE\ngo\n";
  
  print OUT	"create table $SYB_DB.dbo.$TABLE\n";
  
  if($colType[0] =~ "char" || $colType[$c] =~ "bin")
    {
      print OUT "	($columns[0]	$colType[0]($colLen[0])	NULL,\n";
    }
  else
    {
      print OUT "	($columns[0]	$colType[0]	NULL,\n";
    }
  
  for($c = 1; $c < $#columns + 1; $c++)
    {
      if($colType[$c] =~ "char" || $colType[$c] =~ "bin")
	{
	  print OUT "	$columns[$c]	$colType[$c]($colLen[$c])	NULL,\n";
	}
      else
	{
	  print OUT "	$columns[$c]	$colType[$c]	NULL,\n";
	}
    }
  
  print OUT "	)\ngo\n";
  

  &send_sql("select ");
  &send_sql("	col_name(k.id,k.key1), ");
  &send_sql("	col_name(k.id,k.key2), ");
  &send_sql("	col_name(k.id,k.key3), ");
  &send_sql("	col_name(k.id,k.key4), ");
  &send_sql("	col_name(k.id,k.key5), ");
  &send_sql("	col_name(k.id,k.key6), ");
  &send_sql("	col_name(k.id,k.key7), ");
  &send_sql("	col_name(k.id,k.key8) ");
  &send_sql("from syskeys	k, sysobjects o ");
  &send_sql("where	k.id = $table_info[0] ");
  &send_sql("and		k.type = 1 ");
  
  
  #
  # For each record returned 
  #
  
  
  while(@rec = &get_record())
    {
      @cols = @rec;
    }
  
  
  print OUT "sp_dropkey primary, '$TABLE'\n";
  print OUT "\ngo\n";
  print OUT "sp_primarykey '$TABLE'";
  
  foreach $col (@cols)
    {
      if($col)
	{
	  print OUT ", '$col'";
	}
    }
  
  print OUT "\ngo\n";
  
  &send_sql("select ");
  &send_sql("	object_name(k.depid), ");
  &send_sql("	col_name(k.id,k.key1), ");
  &send_sql("	col_name(k.id,k.key2), ");
  &send_sql("	col_name(k.id,k.key3), ");
  &send_sql("	col_name(k.id,k.key4), ");
  &send_sql("	col_name(k.id,k.key5), ");
  &send_sql("	col_name(k.id,k.key6), ");
  &send_sql("	col_name(k.id,k.key7), ");
  &send_sql("	col_name(k.id,k.key8) ");
  &send_sql("from syskeys	k, sysobjects o ");
  &send_sql("where	k.id = $table_info[0] ");
  &send_sql("and		k.type = 2 ");
  
  
  #
  # For each record returned 
  #
  
  
  while(@cols = &get_record())
    {
      
      print OUT "sp_dropkey foreign, '$TABLE', '$cols[0]'";
      print OUT "\ngo\n";
      
      print OUT "sp_foreignkey '$TABLE'";
      
      foreach $col (@cols)
	{
	  if($col)
	    {
	      print OUT ", '$col'";
	    }
	}
      
      print OUT "\ngo\n";
    }
}


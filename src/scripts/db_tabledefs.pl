#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            db_tabledefs.pl
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


$SOURCE_DB_NAME	= $ARGV[0];
$DEST_DB_NAME	= $ARGV[1];
$DB_USER 		= $ARGV[2];
$DB_PWD			= $ARGV[3];


$BASE_DIR	= "./";

%trigger_types = ("I","insert","U","update","D","delete");
%trigger_colname = ("I","instrig","U","updtrig","D","deltrig");
@columns = ();

#
#


#
#	get date/time
#

#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

#$datetime = sprintf("%02d%02d%02d.%02d%02d%02d",
#	$year % 100,
#	$mon + 1,
#	$mday,
#	$hour,
#	$min,
#	$sec);

&set_db($SOURCE_DB_NAME,$DB_USER,$DB_PWD);

#
#	get tablename from db
#

&send_sql($db1, 
	"select o.name, u.name, o.id\n".
    "from sysobjects o, sysusers u\n".
    "where o.type = 'U' and u.uid = o.uid\n".
    "order by o.name\n");



while( (@table = &get_record()) )
{
  
  $out_fn = "$BASE_DIR$SOURCE_DB_NAME.$table[1].$table[0].sql";
  
  open(OUT,">" . $out_fn);

  $TABLE = $table[0];

  print $out_fn,"\n";


  &send_sql("select c.name, t.name, c.length, (c.status & 8) ");
  &send_sql("from syscolumns c, sysobjects o, systypes t, systypes st ");
  &send_sql("where 	c.id = o.id ");
  &send_sql("and		o.name = '$TABLE' ");
  &send_sql("and		c.usertype = st.usertype ");
  &send_sql("and		st.type = t.type ");
  &send_sql("and		t.type < 100 ");
  &send_sql("and		t.usertype != 18 ");

#
# For each record returned 
#
	 

  @columns = ();
  @colType = ();
  @colLen = ();
  @colNull = ();
  
  while(@rec = &get_record())
    {
      $columns[++$#columns] = $rec[0]; 	#add column name to array
      $colType[++$#colType] = $rec[1];	#add column type to array
      $colLen[++$#colLen] = $rec[2];		#add column len to array
      $colNull[++$#colNull] = $rec[3];		#add column len to array
    }

#
# Now the Table Create Script
#


  print OUT	"use $DEST_DB_NAME\ngo\n";
  print OUT	"drop table $DEST_DB_NAME.dbo.$TABLE\ngo\n";
  
  print OUT	"create table $DEST_DB_NAME.dbo.$TABLE\n";
  
  if($colNull[0])
    {
      $null = "NULL";
    }
  else
    {
      $null = "NOT NULL";
    }
  
  if($colType[0] =~ "char" || $colType[$c] =~ "bin")
    {
      print OUT 	"	($columns[0]	$colType[0]($colLen[0])	$null,\n";
    }
  else
    {
      print OUT 	"	($columns[0]	$colType[0]	$null,\n";
    }
  
  for($c = 1; $c < $#columns + 1; $c++)
    {
      if($colNull[$c])
	{
	  $null = "NULL";
	}
      else
	{
	  $null = "NOT NULL";
	}

      if($colType[$c] =~ "char" || $colType[$c] =~ "bin")
	{
	  print OUT 	"	$columns[$c]	$colType[$c]($colLen[$c])	$null,\n";
	}
      else
	{
	  print OUT 	"	$columns[$c]	$colType[$c]	$null,\n";
	}
    }
  
  print OUT	"	)\ngo\n";


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
  &send_sql("where	o.name = '$TABLE' ");
  &send_sql("and		o.id = k.id ");
  &send_sql("and		k.type = 1 ");
  
  
  #
  # For each record returned 
  #
  
  
  while(@rec = &get_record())
    {
      @cols = @rec;
    }
  
  #
  # Now the SYNCDB Table Create Script
  #
  
  print OUT "sp_dropkey primary, '$TABLE'\n";
  print OUT "\ngo\n";
  print OUT "sp_primarykey '$TABLE'";
  
  foreach $col (@cols)
    {
      if($col ne "NULL" && $col)
	{
	  print OUT ", '$col'";
	}
    }
  
  print OUT "\ngo\n";
  
  &send_sql("select ");
  &send_sql("	object_name(k.id), ");
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
  &send_sql("where	o.name = '$TABLE' ");
  &send_sql("and		(		o.id = k.id ");
  &send_sql("			or		o.id = k.depid )");
  &send_sql("and		k.type = 2 ");
  
  
  #
  # For each record returned 
  #
  
  
  while(@cols = &get_record())
    {
      
      print OUT "sp_dropkey foreign, '$cols[0]', '$cols[1]'";
      print OUT "\ngo\n";

      print OUT "sp_foreignkey '$cols[0]'";
      
      $cols[0] = "";
      
      foreach $col (@cols)
	{
	  if($col ne "NULL" && $col)
	    {
	      print OUT ", '$col'";
	    }
	}
      
      print OUT "\ngo\n";
    }
  close(OUT);
}

#
# common keys
#
&send_sql("select ");
&send_sql("	object_name(k.id), object_name(k.depid), ");
&send_sql("	col_name(k.id,k.key1), col_name(k.depid,k.depkey1), ");
&send_sql("	col_name(k.id,k.key2), col_name(k.depid,k.depkey2), ");
&send_sql("	col_name(k.id,k.key3), col_name(k.depid,k.depkey3), ");
&send_sql("	col_name(k.id,k.key4), col_name(k.depid,k.depkey4), ");
&send_sql("	col_name(k.id,k.key5), col_name(k.depid,k.depkey5), ");
&send_sql("	col_name(k.id,k.key6), col_name(k.depid,k.depkey6), ");
&send_sql("	col_name(k.id,k.key7), col_name(k.depid,k.depkey7), ");
&send_sql("	col_name(k.id,k.key8), col_name(k.depid,k.depkey8) ");
&send_sql("from syskeys	k, sysobjects o ");
&send_sql("where	o.name = '$TABLE' ");
&send_sql("and      (       o.id = k.id ");
&send_sql("         or      o.id = k.depid )");
&send_sql("and		k.type = 3 ");



while(@cols = &get_record())
{
  print OUT "sp_dropkey common, '$cols[0]','$cols[1]'\n";
  print OUT "\ngo\n";
  
  print OUT "sp_commonkey '$cols[0]'";
  $cols[0] = "";
  
  foreach $col (@cols)
    {
      if($col && $col ne "NULL")
	{
	  print OUT ", '$col'";
	}
    }
  print OUT "\ngo\n";
}




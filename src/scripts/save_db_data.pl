#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            save_db_data.pl
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


$DB_NAME	= $ARGV[0];
$DB_USER 	= $ARGV[1];
$DB_PWD		= $ARGV[2];


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

$datetime = sprintf("%02d%02d%02d.%02d%02d%02d",
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

&send_sql($db1, 
	  "select o.name, u.name, o.id\n".
	  "from sysobjects o, sysusers u\n".
	  "where o.type = 'U' and u.uid = o.uid\n".
	  "order by o.name\n");



while( (@table = &get_record()) )
{

  #
  #	now get the column name for this table
  #
  

  if($BCP == 0)
    {
      $out_fn =  "$BASE_DIR$DB_NAME.$table[1].$table[0].ins_data.$datetime";
      
      open(OUT,">" . $out_fn);

      &send_sql(
		"select c.name, t.name \n".
		"from   syscolumns c, systypes t, systypes tt\n".
		"where  c.id = $table[2]\n".
		"	and    c.usertype	=  tt.usertype \n".
		"	and    c.name != 'ind_ctn_tst'\n".
		"	and    tt.type		=  t.type \n".
		"	and    t.usertype	<  100 \n".
		"	and    t.usertype	!= 18 \n");
			
      @col_names = ();
      @col_types = ();
      

      while( (@col = &get_record()) )
	{
	  
	  $col_names[@col_names] = @col[0];
	  $col_types[@col_types] = @col[1];
	  
	}
      
      $select = "select ";
      $insert = "insert" . "\t" . $table[1] . "." .$table[0] . "\t(";
      for($c = 0, $cols = @col_names - 1; $c < $cols; $c++)
	{
	  $select .= "\t" . $col_names[$c] . ",";
	  $insert .= "\t" . $col_names[$c] . ",";
	}
      
      $select .= "\t" . $col_names[$c];
      $select .= " from " . $table[1] . "." .$table[0] . "\n";
      
      $insert .= "\t" . $col_names[$c] . ")\n";
      $insert .= "values (";
      
      &send_sql($db2,$select);
      
      $ins = $insert;
      
      $records = 0;
      
      while( (@data = &get_record()) )
	{
	  $records++;
	  $insert = $ins;
	  
	  for($c = 0, $cols = @data - 1; $c < $cols; $c++)
	    {
	      $insert .= "\t";
	      
	      $data[$c] =~ s/\s*$//;
	      if( (($col_types[$c] =~ /date/i) || ($col_types[$c] =~ /char/i)) 
		 && ( $data[$c] ne "NULL") )
		{
		  $insert .= "'" . $data[$c] . "',";
		}
	      else
		{
		  $insert .= $data[$c] . ",";
		}
	      
	    }
	  
	  $data[$c] =~ s/\s*$//;
	  
	  if( (($col_types[$c] =~ /date/i) || ($col_types[$c] =~ /char/i)) 
	     && ( $data[$c] ne "NULL") )
	    {
	      $insert .= "'" . $data[$c] . "')\n";
	    }
	  else
	    {
	      $insert .= $data[$c] . ")\n";
	    }
	  
	  print OUT $insert; 
	  
	}		
      print "Table: $table[0]  Records: $records\n";			
    }
  else
    {
      $out_fn =  "$BASE_DIR$DB_NAME.$table[1].$table[0].data.$datetime";
      
      $stat = system("bcp $DB_NAME.$table[1].$table[0] out $out_fn  -c -t \\\\t -r \\\\n -U$DB_USER -P$DB_PWD");
      
      if($stat != 0)
	{
	  print "Error during BCP of $DB_NAME.$table[1].$table[0]\n";
	}
    }
}



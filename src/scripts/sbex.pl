#!/usr/local/bin/sybperl
# -*- perl -*-
# 
# Title:            sbex.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    11/24/91
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 15:00:23  houghton
# Initial Version.
#
# 


@nul = ('not null','null');
@sysdb = ('master', 'model', 'tempdb');

require "../lib/sybperl.pl";

print "Sybperl version $SybperlVer\n\n";

print "This script tests some of sybperl's functions, and prints out\n";
print "description of the databases that are defined in your Sybase\n";
print "dataserver.\n\n";

# Login to sybase
$dbproc = &dblogin("sa");

# Get a second dbprocess, so that we can select from several
$dbproc2 = &dbopen;	

# chanels simultaneously. We could code things so that this
# feature is unnecessary, but it's good to exercise it.

# First, find out what databases exist:

&dbcmd($dbproc, "select name from sysdatabases order by crdate\n");
&dbsqlexec($dbproc);
&dbresults($dbproc);

database: while((@db = &dbnextrow($dbproc)))
{
  foreach $nm (@sysdb)
    {
      if($db[0] =~ /$nm/)
	{
	  print "'$db[0]' is a system database\n";
	  next database;
	}
    }
  print "Finding user tables in user database $db[0]...";
  
  &dbcmd($dbproc2, "select o.name, u.name, o.id\n"); # 
  &dbcmd($dbproc2, "from $db[0].dbo.sysobjects o, $db[0].dbo.sysusers u\n");
  &dbcmd($dbproc2, "where o.type = 'U' and u.uid = o.uid\n");
  &dbcmd($dbproc2, "order by o.name\n");
  
  &dbsqlexec($dbproc2);
  &dbresults($dbproc2);

  while((@dat = &dbnextrow($dbproc2)))
    {
      $tab = join('@', @dat);	# Save the information
      push(@tables, $tab);	# for later use...
    }
  print "Done.\n";
  
  print "Finding user defined datatypes in database $db[0]...\n";
  
    &dbcmd($dbproc2, "select s.length,substring(s.name,1,30),substring(st.name,1,30)\n");
  &dbcmd($dbproc2, "from   $db[0].dbo.systypes s, $db[0].dbo.systypes st\n");
  &dbcmd($dbproc2, "where  st.type = s.type\n");
  &dbcmd($dbproc2, "and s.usertype > 100 and st.usertype < 100 and st.usertype != 18\n");
  &dbsqlexec($dbproc2);
  &dbresults($dbproc2);
  
  while((@dat = &dbnextrow($dbproc2)))
    {
      print "sp_addtype $dat[1],";
      if ($dat[2] =~ /char|binary/)
	{
	  print "'$dat[2]($dat[0])'";
	}
      else
	{
	  print "$dat[2]";
	}
      print "\n";
      
    }
  print "Done.\n";
  
  print "Now we find the table definition for each user table\nin database $db[0]...\n";
  
  foreach $ln (@tables)		# For each line in the list
    {
      @tab = split('@',$ln);
      
      &dbcmd($dbproc2, "select Column_name = c.name, \n");
      &dbcmd($dbproc2, "       Type = t.name, \n");
      &dbcmd($dbproc2, "       Length = c.length, \n");
      &dbcmd($dbproc2, "       Nulls = convert(bit, (c.status & 8))\n");
      &dbcmd($dbproc2, "from   $db[0].dbo.syscolumns c, $db[0].dbo.systypes t\n");
      &dbcmd($dbproc2, "where  c.id = $tab[2]\n");
      &dbcmd($dbproc2, "and    c.usertype *= t.usertype\n");
      
      &dbsqlexec($dbproc2);
      &dbresults($dbproc2);
      
      print "\nTABLE $db[0].$tab[1].$tab[0]\n ("; 
      $first = 1;
      while((@field = &dbnextrow($dbproc2)))
	{
	  print ",\n" if !$first;		# add a , and a \n if not first field in table
	  
	  print "\t$field[0] \t$field[1]";
	  print "($field[2])" if $field[1] =~ /char|bin/;
	  print " $nul[$field[3]]";
	  
	  $first = 0 if $first;
	}
      print " )\n";
      
      # now get the indexes...
      #
      print "\nIndexes on $db[0].$tab[0].$tab[1]...\n\n";
      &dbuse($dbproc2, $db[0]);
      &dbcmd($dbproc2, "sp_helpindex '$tab[1].$tab[0]'\n");
      
      &dbsqlexec($dbproc2);
      &dbresults($dbproc2);
      
      while((@field = &dbnextrow($dbproc2)))
	{
	  print "unique " if $field[1] =~ /unique/;
	  print "clustered " if $field[1] =~ /^clust/;
	  print "index $field[0]\n";
	  @col = split(/,/,$field[2]);
	  print "on $db[0].$tab[1].$tab[0] (";
	  $first = 1;
	  foreach $ln1 (@col)
	    {
	      print ", " if !$first;
	      $first = 0;
	      print "$ln1";
	    }
	  print ")\n";
	}
      print "\nDone.\n";
    }
  &dbuse($dbproc2, "master");
  @tables = ();
}

&dbexit;


#!/usr/local/bin/sybperl
# -*- perl -*-
# 
# Title:            proc_def.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    11/24/95
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 15:00:22  houghton
# Initial Version.
#
# 


$DB_USER 	= "sa";
$DB_PWD		= "";
$DB_NAME	= "simon";

$dbproc = &dblogin($DB_USER,$DB_PWD);	# Login to sybase
&dbuse($dbproc,$DB_NAME);

while(<>)
{
  if(/^go$/)
    {	
      &dbcmd($dbproc,$cmdbuf);
      $cmdbuf = "";
      &dbsqlexec($dbproc);
      while(&dbresults($dbproc) == $SUCCEED)
	{
	  while((@dat = &dbnextrow($dbproc2)))
	    {
	      foreach $col (@dat)
		{
		  print $col;
		}
	    }
	  print "\n";
	}
      
    }
  else
    {
      $cmdbuf .= $_;
    }
}


&dbexit;


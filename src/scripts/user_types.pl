#!/usr/local/bin/sybperl
# -*- perl -*-
# 
# Title:            user_types.pl
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


$DB_USER 	= "sa";
$DB_PWD		= "";
$DB_NAME	= "simon";

$dbproc = &dblogin($DB_USER,$DB_PWD);	# Login to sybase
&dbuse($dbproc,$DB_NAME);

&dbcmd($dbproc,
	"select upper(s.name), st.name, s.length\n".
	"from systypes s, systypes st\n".
	"where st.type = s.type\n".
		"and s.usertype > 100 ".
		"and st.usertype < 100 ".
		"and st.usertype != 18\n"
	);
	
&dbsqlexec($dbproc);
&dbresults($dbproc);
	   
while((@data = &dbnextrow($dbproc2)))
	{
	if($data[1] =~ /char|binary/)
		{
		print "#define	$data[0]\t";
		$len = length($data[0]) / 4;
			
		for(; $len <  4;$len++)
			{
			print "\t";
			}
	
		print "$data[2]\n";
		}
	}

	
&dbexit;


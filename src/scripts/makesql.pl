#!/usr/local/bin/perldb

#	Title:		makesql
#
#	Description:
#
#		Create objects from source files into database.
#		
#		Executes stagements at end of file or if 'go' is 
#		the first word on a line.
#
#	Input Args:
#
#		makesql src_file, db_name, db_user, db_pwd
#
#		src_file	name of source file or '-' for standard input
#		db_name		database to use
#		db_user		database login name
#		db_pwd		database login password
#
#	DB Access:
#
#		r:	sysobjects
#
#
#	Notes:
#
#		can't have /* more than once on a line or in quoted strings
#
#	Programmer:		Paul Houghton - Sql Solutions Inc.
#
#	Start Date:		1/23/92
#
#	Modification History:
#
#	$Log$
#	Revision 1.1  1992/01/23 20:50:57  paulh
#	Initial revision
#	
#

$version_id = 
	"$Id$";


$SRC_FILE	= $ARGV[0];
$DB_NAME	= $ARGV[1];
$DB_USER 	= $ARGV[2];
$DB_PWD		= $ARGV[3];

open(SRC,"<".$SRC_FILE);

&set_db($DB_NAME,$DB_USER,$DB_PWD);

while(<SRC>)
	{
	if(/\/\*/)
		{
		$comment++;
		}
	if(/\*\//)
		{
		$comment--;
		}
	if($comment < 0)
		{
		die "Confused by comments!";
		}
			
	if(/^\s*create\s+(\w+)\s+(\w*\.*\w*\.*\w+)/i && $comment == 0)
		{
		$obj_type = $1;
		$obj_full_name = $2;

		if($obj_type =~ /table/i || 
			$obj_type =~ /proc/i ||
			$obj_type =~ /trig/i ||
			$obj_type =~ /view/i)
			{
			@obj_name_parts = reverse(split(/\./,$obj_full_name));		
				
			if(length($obj_name_parts[1]) > 0)
				{
				$owner = $obj_name_parts[1];
				}
			else
				{
				$owner = "dbo";
				}
			&send_sql(
				"if exists(select * from sysobjects\n".
							"where name = '$obj_name_parts[0]')\n".
					"drop $obj_type $obj_full_name\n");
			}
		if(/\s+index\s+/i)
			{
			@obj_name_parts = reverse(split);
			
			$index_name = $obj_name_parts[2];

			@tbl_name_parts = reverse(split(/\./,$obj_name_parts[0]));
			$table_name = $tbl_name_parts[0];
			
			&send_sql(
				"if exists(select i.name\n".
						"from sysindexes i, sysobjects o\n".
						"where i.id = o.id\n".
						"and o.name = '$table_name'\n".
						"and i.name = '$index_name')\n".
					"drop index $table_name.$index_name\n");
					
			}

		while(&get_record()){}
		}
	
	
	if(/^go/ && $comment == 0)
		{	
		while((@dat = &get_record())
			{
			foreach $col (@dat)
				{
				print $col,"\t";
				}
			}
		print "\n";		
		}
	else
		{
		&send_sql($_);
		}
	}

while((@dat = &get_record()))
	{
	foreach $col (@dat)
		{
		print $col,"\t";
		}
	print "\n";
	}
exit(0);

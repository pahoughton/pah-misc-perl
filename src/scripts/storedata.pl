#!/usr/local/bin/perldb

#	Title:		savedata
#
#	Description:
#
#		store all database table data from datafiles created by savedata
#		to the database.
#
#	Input Args:
#
#		savedata file_date, db_name, db_user, db_pwd, bcp_flag
#
#		file_date	datestamp from file names.
#		db_name		database to use
#		db_user		database login name
#		db_pwd		database login password
#		bcp_flag	if this is 'bcp' bcp will be used. if it is
#						anything else, insert statements will be 
#						created.
#
#	DB Access:
#
#		r:	sysobjects & user tables
#
#
#	Notes:
#
#	Programmer:		Paul Houghton - SQL Solutions Inc.
#
#	Start Date:		1/23/92
#
#	Modification History:
#
#	$Log$
#	Revision 1.1  1992/01/23 20:51:00  paulh
#	Initial revision
#	
#

$version_id = 
	"$Id$";


$FILE_DATE	= $ARGV[0];
$DB_NAME	= $ARGV[1];
$DB_USER 	= $ARGV[2];
$DB_PWD		= $ARGV[3];
$BCP_FLAG	= $ARGV[3];

#
#	to use bpc set this to 1
#	to use insert staments set this to 0
#
if($BCP_FLAG == 'bcp')
	{
	$BCP = 1;
	}

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

&send_sql( 
	"select o.name, u.name, o.id\n".
    "from sysobjects o, sysusers u\n".
    "where o.type = 'U' and u.uid = o.uid\n".
    "order by o.name\n");

while( (@table = &get_record()) )
	{

	#
	#	now get the column name for this table
	#

#	$in_fn = $DB_NAME . "." . $table[1] . "." .$table[0] . ".data." . $FILE_DATE;

	$in_fn = $BASE_DIR . $table[0] . ".data." . $FILE_DATE;

	print "Truncating Table $DB_NAME.$table[1].$table[0]\n";

	&send_sql(
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

#!/usr/local/bin/perldb

#
# showtables - report tables in a database
#
# Usage: showtables dbname
#
# $Id$
#
# $Log$
# Revision 1.2  1992/01/23 16:09:15  paulh
# Split each table into a file 'table_name.sql'
# Added Comment Header
#
# Revision 1.1  1992/01/23  01:34:32  paulh
# Initial revision
#
#

$usage = "usage: tablescripts.pl dbname\n";

if(@ARGV != 1)
	{
	print $usage;
	exit(1);
	}
	
$dbname = $ARGV[0];

$DB_MSG_REPORT = 1;

&set_db($dbname,"sa");

#
# Get Todays Date 
#
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$today = sprintf("%02d/%02d/%02d",
	$mon + 1,
	$mday,
	$year % 100);

#
# Get Users Real Name
#
@pw_info = getpwuid($>);
$uname = $pw_info[6];


&send_sql("select o.name, u.name, o.id\n",
	"from sysobjects o, sysusers u\n",
	"where o.type = 'U' and u.uid = o.uid\n",
	"order by o.name\n");

	@nul = ('NOT NULL','NULL');

while((@tab = &get_record()))
    {
	&send_sql(
		"select Column_name = c.name, \n",
		"       Type = t.name, \n",
		"       Length = c.length, \n",
		"       Nulls = convert(bit, (c.status & 8))\n",
		"from   syscolumns c, systypes t\n",
		"where  c.id = $tab[2]\n",
		"and    c.usertype *= t.usertype\n");
	
	open(TBL_FILE,">$tab[0].sql");

	print TBL_FILE 
"/*********************************************************************\n",
" * Title:	$dbname.$tab[1].$tab[0]\n",
" *\n",
" * Description:\n",
" *\n",
" *\n",
" *\n",
" * Notes:\n",
" *\n",
" *	Created by 'tablescripts.pl'\n",
" *\n",
" * Programmer:	$uname\n",
" *\n",
" * Start Date:	$today\n",
" *\n",
" * Modification Histroy:\n",
" *\n",
" *	\$Id\$\n",
" *\n",
" *	\$Log\$\n",
" *\n",
" *\n",
" ********************************************************************/\n",
"\nCREATE TABLE TABLE $dbname.$tab[1].$tab[0]\n\t(\n"; 

	while((@field = &get_record()))
		{
		
		if ($field[1] =~ /char|binary/)
			{
			$dbtype = $field[1] . "(" . $field[2] . ")";
			}
		else
			{
			$dbtype = $field[1];
			}
	
		printf(TBL_FILE 
			"\t%-30s  %-35s  %s,\n",$field[0],$dbtype,$nul[$field[3]]);
		}
	print TBL_FILE "\t) on 'default'\n";
	close(TBL_FILE);
	}

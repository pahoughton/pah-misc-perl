#!/usr/local/bin/perldb

#
# tablerows - report number of rows in each table of a database
#
# Usage: tablerows dbname 
#
# $Id$
# 
# $Log$
# Revision 1.1  1992/01/23 01:34:31  paulh
# Initial revision
#
# 

$dbname = $ARGV[0];

$DB_MSG_REPORT = 1;

&set_db($dbname,"sa");

&send_sql("select o.name, u.name, o.id\n",
	"from sysobjects o, sysusers u\n",
	"where o.type = 'U' and u.uid = o.uid\n",
	"order by o.name\n");

	@nul = ('NOT NULL','NULL');

while((@tab = &get_record()))
    {
	&send_sql("select count(*) from $tab[1].$tab[0]\n"); 

	while((@field = &get_record()))
		{

		printf("%-30s Rows: %6d\n",$tab[0],$field[0]);

		}
	}

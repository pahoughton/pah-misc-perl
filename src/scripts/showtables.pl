#!/usr/local/bin/perldb

#
# showtables - report tables in a database
#
# Usage: showtables dbname
#
# $Id$
#
# $Log$
# Revision 1.1  1992/01/23 01:34:30  paulh
# Initial revision
#
#

$dbname = $ARGV[0];

$DB_MSG_REPORT = 1;

&set_db($dbname,"sa");
#
# Get User Defined Data Type Information
#

&send_sql("select s.length,substring(s.name,1,30),substring(st.name,1,30)\n",
	"from   systypes s, systypes st\n",
	"where  st.type = s.type\n",
	"and s.usertype > 100 and st.usertype < 100 and st.usertype != 18\n");

print "User Defined Data types\n\n";

while((@dat = &get_record()))
	{
	if ($dat[2] =~ /char|binary/)
		{
		printf("\t%-30s  %s(%d)\n",$dat[1],$dat[2],$dat[0]);
		}
	else
		{
		printf("\t%-30s  %s\n",$dat[1],$dat[2]);
		}

    }

#
# Get User Defined Data Type Information
#

&send_sql("select o.name, u.name, o.id\n",
	"from sysobjects o, sysusers u\n",
	"where o.type = 'U' and u.uid = o.uid\n",
	"order by o.name\n");

print "\n\nUser Tables\n\n";

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
	
	print "\nTABLE $dbname.$tab[1].$tab[0]\n"; 

	while((@field = &get_record()))
		{

		printf("\t%-30s  %-30s  %3d  %s\n",$field[0],$field[1],$field[2],$nul[$field[3]]);

		}
	}

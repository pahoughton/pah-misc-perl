#!/usr/local/bin/perldb
# -*- perl -*-
# 
# Title:            sync.prn.pl
# 
# Description:
#
#   Memdb Sybase Script Generator
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
# Revision 1.1  1995/11/16 14:58:14  houghton
# Initial Version.
#
# 




$TABLE      = $ARGV[0];
$SYB_PWD    = $ARGV[1];
$SYB_USER   = $ARGV[2];
$SYB_DB     = $ARGV[3];

$SYNCDB     = "sync";
$SYNCTABLE  = "tcsr_syn_tbl";

$SYB_DB = "tnms";
$SYB_USER = "houghton";
$SYB_PWD = "";

%trigger_types = ("I","insert","U","update","D","delete");
%trigger_colname = ("I","instrig","U","updtrig","D","deltrig");
@columns = ();

&set_db($SYB_DB,$SYB_USER,$SYB_PWD);

&send_sql("select c.name, t.name, c.length ");
&send_sql("from syscolumns c, sysobjects o, systypes t, systypes st ");
&send_sql("where    c.id = o.id ");
&send_sql("and      o.name = '$TABLE' ");
&send_sql("and      c.usertype = st.usertype ");
&send_sql("and      st.type = t.type ");
&send_sql("and      t.type < 100 ");
&send_sql("and      t.type != 18 ");

#
# For each record returned 
#
     

while(@rec = &get_record())
{
  $columns[++$#columns] = $rec[0];    #add column name to array
  $colType[++$#colType] = $rec[1];    #add column type to array
  $colLen[++$#colLen] = $rec[2];      #add column len to array
}

#
# For Each of the Types Of Triggers
#

@tt = keys %trigger_types;

open(OUT,">" . $SYB_DB . "." . $TABLE . ".triggers.sql");

print OUT   "use $SYB_DB\ngo\n";

foreach $trig (@tt)
{
  $trigger_name = $TABLE . "_TR_" . $trig;
  
  print OUT   "drop trigger $trigger_name\ngo\n";
  
  $trigger_text = "";
  
  &send_sql("select c.text ");
  &send_sql("from syscomments c, sysobjects o ");
  &send_sql("where        c.id = o.$trigger_colname{$trig} ");
  &send_sql("and      o.type = 'U' ");
  &send_sql("and      o.name = '$TABL' ");
  
  while(@rec = &get_record())
    {
      $trigger_text .= $rec[0];
    }
  
  if(length($trigger_text) > 0)
    {
      if($trigger_text =~ /as\sbegin/)
	{
	  $t_txt = $trigger_text;
	  $t_txt =~ y/a-z/A-Z/;
	  substr($trigger_text,rindex($t_txt,"END"),3)  = "";
	}
      else
	{
	  $trigger_text =~ s/as/as\nbegin/i;
	}
      print OUT $trigger_text;
    }
  else
    {
      print OUT   "create trigger $trigger_name\n" .
	"on $TABLE\n" .
	"for $trigger_types{$trig}\n" .
	"as\n" .
	"\n" .
	"begin\n" .
	"\n" ;
    }

  print OUT   "declare\n" .
    "   @transaction_time   datetime\n" .
    "\n" .
    "select\n" .
    "   @transaction_time = getdate()\n" .
    "\n" .
    "insert $SYNCDB.dbo.$TABLE\n".
    "   ($columns[0],\n";

  for($c = 1; $c < $#columns + 1; $c++)
    {
      print OUT "\t",$columns[$c],",\n";
    }
  
  print OUT   "   typ_mod,\n".
              "   tmx_trn\n".
              "   )\n";

  print OUT   "select\n";
  
  for($c = 0; $c < $#columns + 1; $c++)
    {
      print OUT "\t",$columns[$c],",\n";
    }
  
  print OUT   "   '$trig',\n".
              "   @transaction_time\n".
              "from\n";


  if($trig eq "D")
    {
      print OUT   "   deleted\n";
    }
  else
    {
      print OUT   "   inserted\n";
    }
  
  
  print OUT   "\n".
              "end\n".
              "go\n\n";

}

close(OUT);

#
# Now the SYNCDB Table Create Script
#

open(OUT,">".$SYNCDB.".".$TABLE.".sql");

print OUT   "use $SYNCDB\ngo\n";

print OUT   "drop table $SYNCDB.dbo.$TABLE\n";

print OUT   "go\n";

print OUT   "create table $SYNCDB.dbo.$TABLE\n";

if($colType[0] =~ "char" || $colType[$c] =~ "bin" )
  {
    print OUT   "   ($columns[0]    $colType[0]($colLen[0]) NULL,\n";
  }
else
  {
    print OUT   "   ($columns[0]    $colType[0] NULL,\n";
  }

for($c = 1; $c < $#columns + 1; $c++)
  {
    if($colType[$c] =~ "char" || $colType[$c] =~ "bin")
      {
        print OUT   "   $columns[$c]    $colType[$c]($colLen[$c])   NULL,\n";
      }
    else
      {
        print OUT   "   $columns[$c]    $colType[$c]    NULL,\n";
      }
  }

print OUT   "   typ_mod     char(1) NOT NULL,\n".
            "   tmx_trn     datetime NOT NULL\n".
            "   )\n";

print OUT "\ngo\n";

#
# pri key
#

&send_sql("select ");
&send_sql(" col_name(k.id,k.key1), ");
&send_sql(" col_name(k.id,k.key2), ");
&send_sql(" col_name(k.id,k.key3), ");
&send_sql(" col_name(k.id,k.key4), ");
&send_sql(" col_name(k.id,k.key5), ");
&send_sql(" col_name(k.id,k.key6), ");
&send_sql(" col_name(k.id,k.key7), ");
&send_sql(" col_name(k.id,k.key8) ");
&send_sql("from syskeys k, sysobjects o ");
&send_sql("where    o.name = '$TABLE' ");
&send_sql("and      o.id = k.id ");
&send_sql("and      k.type = 1 ");


print OUT "sp_dropkey primary, '$TABLE'\n";
print OUT "go\n";

while(@rec = &get_record())
  {
    @cols = @rec;
  }


print OUT "sp_primarykey '$TABLE'";

foreach $col (@cols)
  {
    if($col)
      {
        print OUT ", '$col'";
      }
  }

print OUT "\ngo\n";

#
# foreign keys
#
&send_sql("select ");
&send_sql(" object_name(k.depid), ");
&send_sql(" col_name(k.id,k.key1), ");
&send_sql(" col_name(k.id,k.key2), ");
&send_sql(" col_name(k.id,k.key3), ");
&send_sql(" col_name(k.id,k.key4), ");
&send_sql(" col_name(k.id,k.key5), ");
&send_sql(" col_name(k.id,k.key6), ");
&send_sql(" col_name(k.id,k.key7), ");
&send_sql(" col_name(k.id,k.key8) ");
&send_sql("from syskeys k, sysobjects o ");
&send_sql("where    o.name = '$TABLE' ");
&send_sql("and      o.id = k.id ");
&send_sql("and      k.type = 2 ");



while(@cols = &get_record())
  {
    print OUT "sp_dropkey foreign, '$TABLE', '$col[0]'\n";
    print OUT "\ngo\n";
    
    print OUT "sp_foreignkey '$TABLE'";
    foreach $col (@cols)
      {
        if($col)
	  {
            print OUT ", '$col'";
	  }
      }
    print OUT "\ngo\n";
  }



#

# Now the Trigger for the Table We
# Just Built
#

$trigger_name = $TABLE . "_TR_I";

print OUT   "create trigger $trigger_name\n" .
            "on $TABLE\n" .
            "for insert\n" .
            "as\n" .
            "\n" .
            "begin\n" .
            "\n" .
            "insert $SYNCDB.dbo.$SYNCTABLE\n".
            "   (nme_tbl,\n".
            "   tmx_trn)\n".
            "select\n".
            "   '$TABLE',\n".
            "   max(i.tmx_trn)\n".
            "from\n".
            "   inserted    i\n".
            "end\n";

print OUT "\ngo\n";

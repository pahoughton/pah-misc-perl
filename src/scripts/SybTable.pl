#!%TOOL_DIR%/bin/perl
#
# Title:        SybTable.pl
# Project:	SybHelp
# Desc:
# 
#   
# 
# Notes:
# 
# Author:	Paul Houghton - (paul.houghton@wcom.com)
# Created:	02/23/98 05:46
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    $Author$
#   Last Mod:	    $Date$
#   Version:	    $Revision$
#
#   $Id$
#

use Getopt::Long;
use DBI;

my $optRet;

$sybServ    = $ENV{"SYBSERV"} || $ENV{"DSQUERY"};
$sybDb	    = $ENV{"SYBDB"};
$sybUser    = $ENV{"SYBUSER"} || $ENV{"USER"} || $ENV{"LOGNAME"};
$sybPass    = $ENV{"SYBPASS"};


$optRet = GetOptions( 'help', \$help,
		      'sybserv:s', \$sybServ,
		      'sybdb:s', \$sybDb,
		      'sybuser:s', \$sybUser,
		      'sybpass:s', \$sybPass );

if( $help )
  {
    
    print "\nuseage: SybTable\n\n";
    print "    SybTable [options] table table\n\n";
    print "  options:\n\n";
    print "    -help             print this text.\n";
    print "    -sybserv          sybase server (SYBSERV) '$sybServ'.\n";
    print "    -sybdb            database (SYBDB) '$sybDb'.\n";
    print "    -sybuser          sybase login name (SYBUSER) '$sybUser'.\n";
    print "    -sybpass          sybase password (SYBPASS) '$sybPass'.\n";
    print "\n";

    exit 1;
  }

if( ! $sybPass )
  {
    system "stty -echo";
    print "password: ";
    chop( $sybPass = <STDIN> );
    print "\n";
    system "stty echo";
  }
      
      
my $dbh;
my $sth;
  
$dbh = DBI->connect("dbi:Sybase:server=$sybServ", $sybUser, $sybPass ) ||
  die "Conection to '$sybServ' failed - $DBI::errstr." ;


if( $sybDb )
  {
    $dbh->do("use $sybDb") ||
      die "use '$sybDb' failed - $DBI::err." ;
  }

# print "$#ARGV: @ARGV\n";

if( $#ARGV >= 0 )
  {
    foreach $table (@ARGV)
      {
	$sql = 
	  "select c.name, t.name, c.length, c.status \n" .
	  "from syscolumns c, systypes t\n" .
	  "where  c.id = object_id('$ARGV[0]') \n" .
	  "and    c.usertype *= t.usertype \n" ;
	
	print "\n$sybServ:$sybDb..$table\n";
  
	$sth = $dbh->prepare( $sql ) ||
	  die "prepare failed.";
    
	$sth->execute || 
	  die "$DBI::err\n$sth->errstr";
	
	while( @row = $sth->fetchrow )
	  {
	    $name = $row[0];
	    $type = $row[1];
	    $len  = $row[2];
	    $status = $row[3];
	    
	    if( $type =~ "char" || $type =~ "bin")
	      {
		$colType = "$type($len)"; 
	      }
	    else
	      {
		$colType = $type;
	      }
      
	    if( $status & 8 )
	      {
		$isNull = "null";
	      }
	    else
	      {
		$isNull = "not null";
	      }
	    printf("    %-30s  %-15s  %s\n",$name,$colType,$isNull );
	  }
	$sth->finish;
      }
  }
else
  {
    $sql = "select name from sysobjects where type = 'U' order by name";
    
    $sth = $dbh->prepare( $sql ) ||
      die "prepare failed.";
    
    $sth->execute || 
      die "$DBI::err\n$sth->errstr";
      
    while( @dat = $sth->fetchrow )
      {
	print "@dat\n";
      }
    
    $sth->finish;
  }

$dbh->disconnect;
  



#
# $Log$
# Revision 1.1  1999/05/03 14:28:51  houghton
# Initial Version.
#
#

# Local Variables:
# mode:perl
# End:

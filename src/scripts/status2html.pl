#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            status2html.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    9/7/94
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 18:05:08  houghton
# Initial Version.
#
# 


$needPara = 0;

while(<>)
{
  
  if( /^To:\s+(.*)$/ )
    {
      $to = $1;
      next;
    }
  
  if( /^From:\s+(.*)$/ )
    {
      $from = $1;
      next;
    }
  
  if( /^Subject:\s+(.*)$/ )
    {
      $subject = $1;
      next;
    }
  
  if( /^Date:\s+(.*)$/ )
    {
      $date = $1;
      next;
    }
  
  if( /^(\S.*)$/ )
    {
      $body .= "\n<DT> $1\n";
      $body .= "<DD> ";
      next;
    }
  
  
  if( /^\s*$/ )
    {
      if( $needPara )
	{
	  $body .= "    <P>\n";
	  $needPara = 0;
	}
    }
  else
    {
      $body .= $_;
      $needPara = 1;
    }
  
}

print "<TITLE> $from Status Report $date </TITLE>\n";
print "<H2> $from Status Report $date </H2>\n";
print "\n";
print "<B>\n";
print "To: $to <P>\n";
print "From: $from <P>\n";
print "Subject: $subject <P>\n";
print "</B>\n";
print "<HR>\n";
print "<DL>\n";

print $body;
	
print "</DL>\n";




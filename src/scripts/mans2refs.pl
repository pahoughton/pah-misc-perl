#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            mans2refs.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    6/26/94
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 18:05:07  houghton
# Initial Version.
#
# 

while(<>)
{
  foreach $mp (split)
    {
      ($name,$sect) = split(/\./,$mp);
      
      print "     <LI> <A HREF = \"/cgi-bin/man2html?$name($sect)\">$name($sect)</A> man page\n";
    }
}

#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            parsefone.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    3/15/94
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
  chop;
  
  if( $. % 8 == 1 )
    {
      ($last,$first) = split(/, /);
    }
  
  if( $. % 8 ==  2 )
    {
      $mail = $_;
    }
  
  if( $. % 8 == 3 )
    {
      $voice_mail = $_;
    }

  if( $. % 8 == 4 )
    {
      $ext = $_;
    }

  if( $. % 8 == 5 )
    {
      $pager = $_;
    }

  if( $. % 8 == 6 )
    {
      $admin = $_;
    }
  
  if( $. % 8 == 7 )
    {
      $name = $first . " " . $last;
      printf( "%-25s %-6s %10s %13s  %s\n",
	     $name,
	     $mail,
	     $ext,
	     $pager,
	     $admin );
    }
}

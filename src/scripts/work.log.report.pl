#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            work.log.report.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    2/24/93
# 
# Modification History:
#
# $Id$
#
# $Log$
# Revision 1.1  1995/11/16 18:05:09  houghton
# Initial Version.
#
# 



$dbg = 0;

while(<>)
{
  if(/^([0-9\/]*)\s+(\d*):(\d*)\s+(\d*):(\d*)\s+(\S*:\S*)\s*/)
    {
      $date           = $1;
      $start_hr       = $2;
      $start_min      = $3;
      $stop_hr        = $4;
      $stop_min       = $5;
      $task           = $6;
      
      ($month,$day,$year) = ($date =~ /^(\d*)\/(\d*)\/(\d*)/);
      
      $date_task = $date . " " . $task;
      
      $task_hrs = (((($stop_hr - $start_hr) * 60) - 
		    $start_min) + $stop_min) / 60;
      
      if($dbg != 0)
	{   
	  printf("%s\t%02d:%02d %02d:%02d %6.2f %s\n",
		 $date,
		 $start_hr,
		 $start_min,
		 $stop_hr,
		 $stop_min,
		 $task_hrs,
		 $task);
	}

      if($task !~ "PERS")
	{
	  $dt_hrs{$date_task} += $task_hrs;
	  $m_hrs{$month} += $task_hrs;
	}
      
      if($task !~ "NEWWEEK")
	{
	  if($task !~ "PERS")
	    {
	      $d_hrs{$date} += $task_hrs;
	      $t_hrs{$task} += $task_hrs;
	      $total_hrs += $task_hrs;
	    }
	}
      else
	{   
	  @dt_keys = keys %dt_hrs;
	  @dt_k = sort(@dt_keys);
	  
	  foreach $dt (@dt_k)
	    {
	      
	      if($dt =~ /NEWWEEK/)
		{
		  
		  @t_keys = keys %t_hrs;
		  @t_k = sort(@t_keys);
		  
		  printf("\n");
		  foreach $t (@t_k)
		    {
		      printf("\t%6.2f\t%s\n",$t_hrs{$t},$t);
		      delete $t_hrs{$t};
		    }
		  
		  printf("\n");
		  
		  @d_keys = keys %d_hrs;
		  @d_k = sort(@d_keys);
		  
		  foreach $d (@d_k)
		    {
		      printf("\t%6.2f\t%s\n",$d_hrs{$d},$d);
		      delete $d_hrs{$d};
		    }
		  
		  printf("\n%6.2f\t%s\n\n", $wk_hrs,$dt);
		  $wk_hrs = 0;
		}
	      else
		{
		  @DATE_TASK = split(/[   ]/,$dt);
		  if($DATE_TASK[0] ne $prev_date)
		    {
		      print "\n";
		      $prev_date = $DATE_TASK[0];
		    }
		  
		  printf("%6.2f\t%s\n", $dt_hrs{$dt},$dt);
		  $wk_hrs += $dt_hrs{$dt};
		}
	      delete $dt_hrs{$dt};
	    }
	}
    }
}


@mh_keys = keys %m_hrs;

foreach $m (@mh_keys)
{
  print "\Month: $m   Hours: $m_hrs{$m}\n";
}

print "\nTotal Hours: ",$total_hrs,"\n";

#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            time.report.pl
# 
# Description:
# 
# 	
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    1/11/94
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



#
#	Time Report
#

$DEBUG = 0;

@julianDate = (0,31,59,90,120,151,181,212,243,273,304,334);
@daysInMonth = (31,28,31,30,31,30,31,31,30,31,30,31);

$prevYear      = 0;
$prevStartTime = 0;
$prevTaskMajor = "PERS";
$prevTaskMinor = "";

while(<>)
{
#
# looking for: ^00/00/00 09:30 xxx
#
  
  if(/^(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+)\s+(\S.+)/)
    {
      $taskMonth    = $1;
      $taskDate	    = $2;
      $taskYear	    = $3;
      
      $taskHour	    = $4;
      $taskMin	    = $5;
      $task	    = $6;
      
#
# looking for xxx:yyy
#
      
      if( $task =~ /(\S+):(\S*)/ )
	{
	  $taskMajor = $1;
	  $taskMinor = $2;
	}
      else
	{
	  $taskMajor = $task;
	  $taskMinor = "";
	}
      
      $taskJdate = $julianDate[$taskMonth - 1] + $taskDate;
      
      $startTime = ( ($taskJdate * 24 * 60) +
		     ($taskHour * 60) +
		     $taskMin );
      
      if( $taskYear % 4 == 0 && $taskMonth > 2 )	#is it leap year
	{
	  $taskJdate++;
	  $startTime += 24 * 60;
	}
      
      $prevTaskTime = $startTime - $prevStartTime;
      
      if( $prevYear != $taskYear )
	{
	  $prevTaskTime += 365 * 24 * 60;
	  
	  if( $prevYear % 4 == 0 )
	    {
	      $prevTaskTime += 24 * 60;
	    }
	}
      
#
# did the previous task span multable days?
#
      
      
      for( $days = 0, $multiDayTaskTime = ($prevTaskTime % (24 * 60));
	   $prevTaskTime > (($taskHour * 60) + $taskMin) && $prevYear != 0;
	   $days++, $prevTaskDate++, $prevTaskTime -= $multiDayTaskTime,
	   $multiDayTaskTime = 24 * 60)
	{
	  if( $DEBUG )
	    {
	      print "$taskDate $taskHour $taskMin - $prevTaskTime - $days\n";
	    }
#
# need multi month handling!
#
	  
	  
	  if( $prevTaskDate >  $daysInMonth[$prevTaskMonth - 1] )
	    {
	      $prevTaskDate = 1;
	      $prevTaskMonth = (((11 + $prevTaskMonth) - 1) % 12) + 1;
	    }
	  
	      $taskday = sprintf("%02d/%02d/%02d %s",
				 $prevTaskMonth,
				 $prevTaskDate,
				 $prevYear,
				 $prevTaskMajor);
	      
	      $taskDateHours{ $taskday } += $multiDayTaskTime;
	      
	  if( $prevTaskMajor !~ "PERS" )
	    {
	      $day = sprintf("%02d/%02d/%02d",
			     $prevTaskMonth,
			     $prevTaskDate,
			     $prevYear);
	      
	      
	      $dateHours{ $day } = $multiDayTaskTime;
	    }
	  
	  if( $DEBUG ) 
	    {
	      printf("Multi Day: %02d/%02d/%02d %s - %d\n",
		     $prevTaskMonth,
		     $prevTaskDate,
		     $prevYear,
		     $prevTaskMajor,
		     $multiDayTaskTime);
	    }
	}
      
      if( $prevTaskMajor !~ "PERS" )
	{
	  
	  $taskday = sprintf("%02d/%02d/%02d %s",
			     $taskMonth,
			     $taskDate,
			     $taskYear,
			     $prevTaskMajor);
	  
	  
	  $taskDateHours{ $taskday } += $prevTaskTime;
	  
	  $day = sprintf("%02d/%02d/%02d",
			 $taskMonth,
			 $taskDate,
			 $taskYear);
	  
	  
	  $dateHours{ $day } += $prevTaskTime;
	  
	}
      
# 1/1/70 was a thursday(4)
      
      $weekDay = (($taskYear - 70) + (($taskYear - 69) / 4)
		  + 3 + $taskJdate) % 7;
      
      
      
      
      if( $DEBUG )
	{ print "$taskday - $taskDateHours{$taskday}\n"; }
      
      $prevYear      = $taskYear;
      $prevTaskDate  = $taskDate;
      $prevTaskMonth = $taskMonth;
      $prevStartTime = $startTime;
      $prevTaskMajor = $taskMajor;
      $prevTaskMinor = $taskMinor;
      
    }
}
  
  @dateKeys = sort( keys(%dateHours) );
  
  foreach $dateKey (@dateKeys)
    {
      printf("%6.2f\t%s\n", $dateHours{$dateKey} / 60,$dateKey);
    }
  
    
  @taskDateKeys = sort( keys(%taskDateHours) );
  
  foreach $taskDateKey (@taskDateKeys)
    {
      if($taskDateKey =~ /^(\d+)\/(\d+)\/(\d+)\s+(\S.+)/)
    	{
	  $taskMonth    = $1;
	  $taskDate	= $2;
	  $taskYear	= $3;
	  $taskMajor	= $4
	}
      else
	{
	  die "Task Date Key Error: $taskDateKey\n";
	}
      
# 1/1/70 was a thursday(4)

      $taskJDate = $julianDate[$taskMonth - 1] + $taskDate;
      
      $weekDay = (($taskYear - 70) + (($taskYear - 69) / 4)
		  + 3 + $taskJDate) % 7;

      
      if( $dayHours == 0)
	{
	      if( $weekDay != 6 && $weekDay != 0 && $taskJDate != $prevTaskJDate )
		{
		  $monthWorkDays++;
		}
	  $prevTaskJDate = $taskJDate;
	}
      else
	{

	  if( $taskJDate != $prevTaskJDate )
	    {
	      printf(" - %6.2f \n",$dayHours / 60);
	      $dayHours = 0;
	      $prevTaskJDate = $taskJDate;

	      if( $weekDay != 6 && $weekDay != 0 )
		{
		  $monthWorkDays++;
		}
	    }
	  else
	    {
	      if( $taskDateKey !~ /PERS/  )
		{
		  printf("\n");
		}
	    }
	}

      if(  $weekDay == 6 && $prevTaskWJDate != $taskJDate )
	{
	  printf("\n-- WEEK HOURS: %.2f\n\n",$weekHours/ 60);
	  $prevTaskWJDate = $taskJDate;
	  $weekHours = 0;
	}

      if( $taskMonth != $prevTaskMonth )
        {
	  printf("\n-- MONTH HOURS: (%d)  %.2f\n\n", 
		 $monthWorkDays * 8,
		 $monthHours / 60);
	  $prevTaskMonth = $taskMonth;
	  $monthHours = 0;
	  $monthWorkDays = 0;
	}

      if( $taskDateKey !~ /PERS/ )
	{
	  $weekHours += $taskDateHours{$taskDateKey};
	  $monthHours += $taskDateHours{$taskDateKey};
	  $dayHours += $taskDateHours{$taskDateKey};

	  printf("%6.2f\t%s", $taskDateHours{$taskDateKey} / 60,$taskDateKey);
	}

    }
  
  printf(" - %6.2f \n",$dayHours / 60);
  $dayHours = 0;
  $prevTaskJDate = $taskJDate;

  if( $weekDay != 6 && $weekDay != 0 )
    {
      $monthWorkDays++;
    }
  printf("\n-- WEEK HOURS: %.2f\n\n",$weekHours/ 60);
  printf("\n-- MONTH HOURS: (%d)  %.2f\n\n", 
	 $monthWorkDays * 8,
	 $monthHours / 60);






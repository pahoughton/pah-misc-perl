#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            time.sheet
# 
# Description:
# 
#   Generate a timesheet from log
# 
# Notes:
# 
# Programmer:	    Paul Houghton - (paul_houghton@wiltel.com)
# 
# Start Date:	    6/23/94
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

$DEBUG = 0;


%taskOrder = ( "WILBAN",	"01",
	      "WILPAK",		"02",
	      "NAMESRV",	"03",
	      "CF",		"04",
	      "CORE",		"05",
	      "TOOLS",		"06",
	      "RATING",		"07",
	      "SICK",		"08",
	      "ST_DIS",		"09",
	      "VAC",		"10",
	      "HOLY",		"11",
	      "FLOAT",		"12",
	      "FAM_ILL",	"13",
	      "BEREAV",		"14",
	      "INJURY",		"15",
	      "MIL_LEV",	"16",
	      "JURY",		"17",
	      "NP_OVER",	"18",
	      "INT_MEET",	"19",
	      "TRAIN",		"20",
	      "COMP",		"21",
	      "OTHER",		"22"
	     );

$doubeLine = 07;

%taskList = ("WILBAN",	"T00443-005\nWilband Prod Supp",
	     "WILPAK",	"T03090-005\nWilPak SNMP Agent",
	     "NAMESRV", "T03180-005\nCF Name Server",
	     "CF",	"T92069-005\nCF Prod Support",
	     "CORE",	"T98033-011\nCentral Repos/TQM",
	     "TOOLS",	"T98033-013\nTools",
	     "RATING",	"T98033-015\nRating",
	     "SICK",	"Sick",
	     "ST_DIS",	"Short Trm Dis",
	     "VAC",	"Vacation",
	     "HOLY",	"Holiday",
	     "FLOAT", 	"Float Hol",
	     "FAM_ILL",	"Illness Fam",
	     "BEREAV",	"Bereavement",
	     "INJURY",	"Injury",
	     "MIL_LEV",	"Military Leave",
	     "JURY",	"Jury Duty",
	     "NP_OVER", "NonProd Overtime",
	     "INT_MEET","Int Meetings",
	     "TRAIN",	"Training",
	     "COMP",	"Comp Time",
	     "OTHER",	"Other"
	    );




@julianDate = (0,31,59,90,120,151,181,212,243,273,304,334);
@daysInMonth = (31,28,31,30,31,30,31,31,30,31,30,31);
@daysOfWeek = ("Sat","Sun","Mon","Tue","Wed","Thr","Fri", );

$prevYear      = 0;
$prevStartTime = 0;
$prevTaskMajor = "PERS";
$prevTaskMinor = "";

sub GenTimeSheet
{
  print "Weekly Timesheet - Paul Houghton - Week Ending $endOfWeek\n\n";

  print "Code: PAH  Dept: ????\n";
  
  print "                     Sat   Sun   Mon   Tue   Wed   Thu   Fri   Total";

    
  %orderTask = ();
  
  foreach $task ( keys(%taskHours) )
    {
      $orderTask{$taskOrder{$task}} = $task;
    }
  
#    @orderKeys = sort( keys( %orderTask ) );

  foreach $k (sort( keys( %orderTask ) ) )
    {
      if( $k > 7 )
	{
	  printf("\n\n%-19s",$taskList{ $orderTask{$k} } );
	}
      else
	{
	  printf("\n\n%-30s",$taskList{ $orderTask{$k} } );
	}
      
      $tdays = 0;
      foreach $day (split(/,/,$taskHours{ $orderTask{$k} } ) )
	{
	  $tdays++;
	  if( $day == 0 )
	    {
	      print "   .  ";
	    }
	  else
	    {
	      printf("%6.2f",$day );
	    }
	}
      
      for(; $tdays < 7 ; $tdays++)
	{
	  print "   .  ";
	}
      
      printf("%8.2f",$taskWeekHours{$orderTask{$k}});
    }
  
  printf("\n\n%-19s","Totals");
  
  
  $totalWeekHours = 0;
  for( $wday = 0; $wday < 7; $wday++ )
    {
      if( $dayOfWeekHours[$wday] == 0 )
	{
	  print "   .  ";
	}
      else
	{
	    printf("%6.2f",$dayOfWeekHours[$wday] );
	  }
      $totalWeekHours += $dayOfWeekHours[$wday];
    }
  
  printf("%8.2f\n\n",$totalWeekHours);
  
  #  @taskKeys = sort( keys(%taskHours) );
  
  #  foreach $task (@taskKeys)
  #  {
  # $dayOfWeekHours
  # $taskWeekHours
  
  
  #      print "$task - $taskHours{$task} \n";
  #  }
  
  
}
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
	      + 4 + $taskJDate) % 7;
  
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
  
  if(  $weekDay == 0 && $prevTaskWJDate != $taskJDate )
    {
      &GenTimeSheet( );
      %taskHours = ();
      %taskLastWeekDay = ();
      %taskWeekHours = ();
      @dayOfWeekHours = ();
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
      
      while( $taskLastWeekDay{$taskMajor} + 1 < $weekDay + 1 )
	{
	  $taskHours{$taskMajor} .= "0,";
	  $taskLastWeekDay{$taskMajor}++;
	}
      
      $taskHours{$taskMajor} .=
	sprintf("%.2f,",$taskDateHours{$taskDateKey} / 60 );
      
      $dayOfWeekHours[$weekDay] += $taskDateHours{$taskDateKey} / 60;
      $taskWeekHours{$taskMajor} += $taskDateHours{$taskDateKey} / 60;
      
      $taskLastWeekDay{$taskMajor}++;
      
      $endOfWeek = sprintf("%d/%d/%d",
			   $taskMonth,
			   $taskDate,
			   $taskYear );
      
      
      printf("%6.2f\t %s  %s",
	     $taskDateHours{$taskDateKey} / 60,
	     $daysOfWeek[$weekDay],
	     $taskDateKey);
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






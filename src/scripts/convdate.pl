#!/usr/local/bin/perl
# -*- perl -*-
# 
# Title:            convdate.pl
# 
# Description:
# 
# 	
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
# $Log :$
# 



#!/u/houghton/tools/bin/perldb
;# convdate  convert clarion date value to a date string
;#

sub convdate 
	{
	package convdate;


	$clarion_date = pop(@_) - 4;

	if($clarion_date > 0)
		{
			@month_days = (31,28,31,30,31,30,31,31,30,31,30,31);

			$fourYearDateCount	= 365 + 365 + 365 + 366;
			$centuryDateCount	= ($fourYearDateCount * 25) - 1;



		$centuryCount	= int( $clarion_date / $centuryDateCount );

		$clarion_date	-= $centuryDateCount * $centuryCount;

		$fourYearsCount = int( $clarion_date / $fourYearDateCount );

		$clarion_date	-= $fourYearsCount * $fourYearDateCount;

		$yearCount		= int( $clarion_date / 365 );

		$clarion_date	-= $yearCount * 365;

		$year = ($centuryCount * 100) + 
				($fourYearsCount * 4) + 
				$yearCount + 1801;

		if($yearCount == 3)
			{
			$month_days[1]++;
			}
		
		$month = 0;

		while( $clarion_date >= $month_days[$month] )
			{
			$clarion_date -= $month_days[$month];
			$month++;
			}

		$clarion_date++;
		$month++;

		sprintf("%d/%d/%d",$month,$clarion_date,$year);
		}
	else
		{
		sprintf("");
		}
	}
1;

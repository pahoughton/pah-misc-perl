
@DaysInMonth = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 0);

sub YYMMDDtoJD
{

    local( $dateStr ) = pop( @_ );

    $jdate = 0;
    
    if( $dateStr ~= /(\d\d)(\d\d)(\d\d)/ )
    {
	$year = $1;
	$month = $2;
	$mdate = $3;
	
	if( year % 4 == 0 )
	{
	    $isLeap = 1;
	}
	else
	{
	    $isLeap = 0;
	}

	for( $m = 0; $m < $month; $m++ )
	{
	    $jdate += $DaysInMonth[$m];
	}

	if( $isLeap && $month > 2 )
	{
	    $jdate++;
	}

	$jdate += $mdate;
	    
    }
    else
    {
	$jdate = -1;
    }

    $jdate;
}

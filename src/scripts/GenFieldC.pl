#!/usr/local/bin/perl

($className, $ext) = split(/\./,$ARGV[0] );

open( INPUT, "<$ARGV[0]" );


$useFiller = 0;

while(<INPUT>)
{
    chop;
    
    ($name, $len, $type) = split(/ +/);

    if( $name eq "FILLER" )
    {
	$useFiller = 1;
	$filler = $len;
	next;
	
    }
    

    $UpperName = $name;
    $UpperName =~ y/a-z/A-Z/;

    $startName = "$UpperName" . "_START";
    $lenName   = "$UpperName" . "_LEN";

    if( $useFiller )
    {
	printf "#define %-25s (%s + %s + $filler)\n",$startName, $prev_start, $prev_len;
	$useFiller = 0;
    }
    else
    {
	printf "#define %-25s (%s + %s)\n",$startName, $prev_start, $prev_len;
    }
    printf "#define %-25s %d\n\n", $lenName, $len;

    $flds .= sprintf( "  { %-25s %-25s %-25s FieldInfo::%s },\n",
    "\"$name\",",
    "$startName,",
    "$lenName,",
    $type );

    $prev_start = $startName;
    $prev_len = $lenName;

}

print "FieldInfo $className::Fields[] = \n";
print "{\n";
print $flds;
print "  { 0, 0, 0, 0 },\n";
print "};\n";


#!/usr/local/bin/perl

($className, $ext) = split(/\./,$ARGV[0] );

open( DEF, "<$ARGV[0]" );

%dbType2cType = ( "smallint",	"short",
		 "char",    	"char",
		 "varchar",	"char",
		 "int",	    	"long" );

%dbType2argType = ("smallint",	"short",
		   "char",  	"const char *",
		   "varchar",	"const char *",
		   "int",   	"long" );

#
# translate from abc_def_ghi to abcDefGhi
#
sub Name2VarName
{
    local( $name ) = $_[0];
    local( $varName ) = "";
    
    @nameParts = split(/_/,$name);

    $first = 1;
    
    foreach $part (@nameParts)
    {
	if( $first )
	{
	    $varName .= $part;
  	    $first = 0;
	    next;
	}
	substr($part,0,1) =~ tr/a-z/A-Z/;
	$varName .= $part;
    }

    $varName;
}

#
# translate from abc_def_ghi to ABC_DEF_GHI
#

sub Name2UpperName
{
    local( $name ) = $_[0];
    $name =~ y/a-z/A-Z/;

    $name;
}

#
# translate from abc_def_ghi to AbcDefGhi
#

sub Name2MethName
{
    local( $name ) = $_[0];
    local( $methName ) = "";
    
    @nameParts = split(/_/,$name);
    
    foreach $part (@nameParts)
    {
	substr($part,0,1) =~ tr/a-z/A-Z/;
	$methName .= $part;
    }

    $methName;
}

open( HH ,">$className.hh");

$fieldCount = 0;
while( <DEF> )
{
    if( /\s*(\w+)\s+(\w+)\(*(\d*)\)*/ )
    {
	$names[$fieldCount] 	    = $1;
	$types[$fieldCount] 	    = $2;
	$lens[$fieldCount]   	    = $3;
	
	$varNames[$fieldCount] 	    = &Name2VarName( $1 );
	$upperNames[$fieldCount]    = &Name2UpperName( $1 );
	$methNames[$fieldCount]	    = &Name2MethName( $1 );

	$fieldCount++;

    }
}

print HH "#include <Common.h>\n";
print HH "#include <iostream.h>\n";
print HH "#include <ValidRecord.hh>\n";
print HH "#include <FieldInfo.hh>\n\n";

print HH "typedef struct\n";
print HH "{\n";

    
for( $f = 0; $f < $fieldCount; $f++ )
{    
    
    if( $dbType2cType{ $types[$f] } eq "char" )
    {
	printf( HH "  %-20s %s[ $lens[$f]+1 ];\n",
	       $varNames[$f],
	       $dbType2cType{ $types[$f] } );
    }
    else
    {
	printf( HH "  %-20s %s;\n",
	       $varNames[$f],
	       $dbType2cType{ $types[$f] } );
    }
}

print HH "} $className"."Data;\n";
print HH "\n";

    
print HH "class $className : public ValidRecord\n";
print HH "{\n\n";
print HH "public:\n\n";
print HH "  $className( ";

printf HH " %-15s %s",$dbType2argType{ $types[0] },$names[0];

for( $f = 1; $f < $fieldCount; $f++ )
{
    printf HH ",\n        %-15s %s",$dbType2argType{ $types[$f] },$varNames[$f];
}

print HH " );\n\n";
print HH "  ~$className() {};\n\n";
print HH "  enum FieldNumber\n";
print HH "  {\n";

for( $f = 0; $f < $fieldCount; $f++ )
{
    printf HH "    $upperNames[$f],\n";
}

print HH "    FLD_UNDEFINED\n";
print HH "  };\n\n";
    



#!/usr/local/bin/perl


%methReturnTypes = ("TBCDP",   	"const TbcDigitPack &",
		    "PINDP",	"const Pin &",
		    "USHORT", 	"unsigned short",
		    "STRING", 	"const char *",
		    "ESTRING", 	"const char *",
		    "CHAR",   	"char",
		    "ULONG",  	"unsigned long",
		    "BOOL",   	"Bool" );

%bitMeth = ("TBCDP",    "getTbcd",
	    "PINDP",	"getTbcd",
	    "USHORT",  	"getUShort",
	    "ULONG",   	"getULong",
	    "STRING",  	"getStr",
	    "ESTRING",  "getStr",
	    "CHAR",    	"getChar",
	    "BOOL",    	"getUShort" );

%varTypes = ("TBCDP", 	"TbcDigitPack",
	     "PINDP",	"Pin",
	     "STRING",	"char",
	     "ESTRING",	"char" );
		 

($className, $ext) = split(/\./,$ARGV[0] );

open( DEF, "<$ARGV[0]" );


#
# build the header file
#

open( "HH", ">$className.hh" );

print HH "#include <Common.h>\n";
print HH "#include <iostream.h>\n";
print HH "#include <BitPackNet.hh>\n";
print HH "#include <FieldInfo.hh>\n\n";

    
print HH "class $className : public BitPackNet\n";
print HH "{\n\n";
print HH "public:\n\n";
print HH "  $className( char * rawRec );\n";
print HH "  ~$className() {};\n\n";
print HH "  enum FieldNumber\n";
print HH "  {\n";

while( <DEF> )
{
    chop;

    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }

    $UpperName = $name;
    $UpperName =~ y/a-z/A-Z/;

    print HH "    $UpperName,\n";

}

print HH "    FLD_UNDEFINED\n";
print HH "  };\n\n";

seek( DEF, 0, 0);

while( <DEF> )
{
    chop;

    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }

    @mfn = split(/_/,$name);

    #
    # translate from abc_def_ghi to AbcDefGhi
    #
    
    foreach $mfnp (@mfn)
    {
	substr($mfnp,0,1) =~ tr/a-z/A-Z/;
	$methFldName .= $mfnp;
    }
        
    printf HH "  %-20s get%s( void ) const;\n",$methReturnTypes{$type},$methFldName;

    $methFldName = "";
    
}

print HH "\n\n";

print HH "  const char *         getFieldName( FieldNumber field );\n";
print HH "  unsigned short       getFieldSize( FieldNumber field );\n";
print HH "  FieldInfo::DataType  getFieldType( FieldNumber field );\n\n";

print HH "  friend ostream & operator<<( ostream & dest, const $className & rec);\n\n";

print HH "protected: \n\n";
print HH "  static const FieldInfo Fields[];\n\n";
print HH "private:\n\n";
print HH "  $className( const $className & copyFrom );\n";
print HH "  $className & operator=( const $className & assignFrom );\n\n";

seek( DEF, 0, 0 );

while( <DEF> )
{
    
    chop;

    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }
    if( $type ne "TBCDP" &&
       $type ne "PINDP" &&
       $type ne "STRING" &&
       $type ne "ESTRING" )
    {
	next;
    }
    

    @vfn = split(/_/,$name);

    $first = 1;
    
    foreach $vfnp (@vfn)
    {
	if( $first )
	{
	    $varName .= $vfnp;
  	    $first = 0;
	    next;
	}
	substr($vfnp,0,1) =~ tr/a-z/A-Z/;
	$varName .= $vfnp;
    }

    if( $type eq "TBCDP" || $type eq "PINDP" )
    {
	printf HH "  %-15s $varName;\n",$varTypes{ $type };
    }
    else
    {
	printf HH "  %-15s $varName[$len+1];\n",$varTypes{ $type };
    }

    $varName = "";
    

}
    
print HH "};\n\n";

print HH "//\n";
print HH "// Inline methods\n";
print HH "//\n\n";

print HH "inline\n";
print HH "$className::$className( char * rawRec )\n";
print HH "  : BitPackNet( rawRec ) \n";
print HH "{\n";

seek( DEF, 0, 0 );

while( <DEF> )
{
    chop;

    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }
    if( $type ne "TBCDP" &&
       $type ne "PINDP" &&
       $type ne "STRING" &&
       $type ne "ESTRING" )
    {
	next;
    }
    

    @vfn = split(/_/,$name);

    $first = 1;
    
    foreach $vfnp (@vfn)
    {
	if( $first )
	{
	    $varName .= $vfnp;
  	    $first = 0;
	    next;
	}
	substr($vfnp,0,1) =~ tr/a-z/A-Z/;
	$varName .= $vfnp;
    }

    $UpperName = $name;
    $UpperName =~ y/a-z/A-Z/;

    if( $type eq "TBCDP" || $type eq "PINDP" )
    {
	print HH "  $varName.set( *this, Fields[ $UpperName].getStart(),\n";
	print HH "      Fields[ $UpperName].getLen() );\n\n";
    }

    if( $type eq "STRING" )
    {
	print HH "  SafeStrcpy( $varName, $bitMeth{ $type }( ";
	print HH "Fields[ $UpperName ].getStart() ),";
	print HH "sizeof( $varName ) );\n";	   
    }

    if( $type eq "ESTRING" )
    {
	print HH "  SafeStrcpy( $varName, $bitMeth{ $type }( ";
	print HH "Fields[ $UpperName ].getStart() ),";
	print HH "sizeof( $varName ) );\n";
	print HH "  EbcdicToAscii( $varName, 0 );\n";
    }

    $varName = "";
    

}

print HH "  return;\n";
print HH "}\n\n";


seek( DEF, 0, 0 );

while( <DEF> )
{
    chop;
    
    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }
    
    $UpperName = $name;
    $UpperName =~ y/a-z/A-Z/;

    @mfn = split(/_/,$name);

    foreach $mfnp (@mfn)
    {
	substr($mfnp,0,1) =~ tr/a-z/A-Z/;
	$methFldName .= $mfnp;
    }


    @vfn = split(/_/,$name);

    $first = 1;
    
    foreach $vfnp (@vfn)
    {
	if( $first )
	{
	    $varName .= $vfnp;
  	    $first = 0;
	    next;
	}
	substr($vfnp,0,1) =~ tr/a-z/A-Z/;
	$varName .= $vfnp;
    }

    print  HH "inline $methReturnTypes{$type}\n";
    print  HH "$className::get$methFldName( void ) const\n";
    print  HH "{\n";


    
    if( $type eq "TBCDP" ||
       $type eq "PINDP" ||
       $type eq "STRING" ||
       $type eq "ESTRING" )
    {
	print HH "  return( $varName );\n";
    }
    else
    {
	print HH "  return( $bitMeth{$type}( Fields[ $UpperName].getStart(), \n";
	print HH "                       Fields[ $UpperName ].getLen() ) );\n";
    }

    print HH "}\n\n";

    $methFldName = "";
    $varName = "";
    
}


close( HH );

open( FLDC, ">$className"."Field.C" );

print HH "#include <Common.h>\n";
print HH "#include <$className.hh>\n";

seek( DEF, 0, 0 );

$first = 1;

while( <DEF> )
{
    chop;
    
    ($name, $len, $type) = split(/[ \t]+/);

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

    if( $first )
    {
	printf FLDC "#define %-25s 0\n",$startName;
	$first = 0;
    }
    else
    {
	if( $useFiller )
	{
	    printf FLDC "#define %-25s (%s + %s + $filler)\n",
	    	$startName, $prev_start, $prev_len;
	    $useFiller = 0;
	}
	else
	{
	    printf FLDC "#define %-25s (%s + %s)\n",
	    	$startName, $prev_start, $prev_len;
	}
    }
    printf FLDC "#define %-25s %d\n\n", $lenName, $len;

    if( $type eq "ESTRING" )
    {
	$fldsType = "STRING";
    }
    else
    {
	$fldsType = $type;
    }
    
    $flds .= sprintf( "  { %-25s %-25s %-25s FieldInfo::%s },\n",
    "\"$name\",",
    "$startName,",
    "$lenName,",
    $fldsType );

    $prev_start = $startName;

    $prev_len = $lenName;

    if( $type eq "STRING" || $type eq "ESTRING" )
    {
	$prev_len = "($lenName * 8)";
    }

    if( $type eq "TBCDP" || $type eq "PINDP" )
    {
	$prev_len = "($lenName * 4)";
    }
    

}

print FLDC "FieldInfo $className::Fields[] = \n";
print FLDC "{\n";
print FLDC $flds;
print FLDC "  { 0, 0, 0, 0 },\n";
print FLDC "};\n";

    
close( FLDC );

open( CSRC , ">$className".".C" );

print CSRC "#include <$className.hh>\n\n";
print CSRC "ostream & \n";
print CSRC "operator<<( ostream & dest, const $className & rec )\n";
print CSRC "{\n\n";
print CSRC "   dest ";

seek( DEF, 0, 0 );

while( <DEF> )
{
    chop;

    ($name, $len, $type) = split(/[ \t]+/);

    if( $name eq "FILLER" )
    {
	next;
    }

    @mfn = split(/_/,$name);

    #
    # translate from abc_def_ghi to AbcDefGhi
    #
    
    foreach $mfnp (@mfn)
    {
	substr($mfnp,0,1) =~ tr/a-z/A-Z/;
	$methFldName .= $mfnp;
    }
        
    printf CSRC "<< rec.get$methFldName() << ' '\n        ";

    $methFldName = "";
    
}

print CSRC ";\n\n";
print CSRC "}\n\n";




#!/usr/local/bin/perl

%types = ("TBCD",   "TbcDigit",
	  "USHORT", "unsigned short",
	  "STRING", "const char *",
	  "ESTRING", "const char *",
	  "CHAR",   "char",
	  "ULONG",  "unsigned long",
	  "BOOL",   "Bool" );

%meth = ("TBCD",    "getChar",
	 "USHORT",  "getShort",
	 "STRING",  "getStr",
	 "ESTRING",  "getStr",
	 "CHAR",    "getChar",
	 "ULONG",   "getLong",
	 "BOOL",    "getShort" );


($className, $ext) = split(/\./,$ARGV[0] );

open( INPUT, "<$ARGV[0]" );

print "#include <iostream.h>\n";
print "#include <BitPackNet.hh>\n";
print "#include <FieldInfo.hh>\n\n";

    
print "class $className : public BitPackNet\n";
print "{\n\n";
print "public:\n\n";
print "  $className( char * rawRec );\n";
print "  ~$className() {};\n\n";
print "  enum FieldNumber\n";
print "  {\n";

while(<INPUT>)
{

    chop;
    
    ($name, $len, $type) = split(/ +/);

    if( $name eq "FILLER" )
    {
	next;
    }
    
    $UpperName = $name;
    $UpperName =~ y/a-z/A-Z/;

    print "    $UpperName,\n";
}

print "  };\n\n";

seek( INPUT, 0, 0);

while(<INPUT>)
{

    chop;
    
    ($name, $len, $type) = split(/ +/);

    if( $name eq "FILLER" )
    {
	next;
    }
    
    @mfn = split(/_/,$name);

    foreach $mfnp (@mfn)
    {
	substr($mfnp,0,1) =~ tr/a-z/A-Z/;
	$methFldName .= $mfnp;
    }
        
    printf "  %-15s get%s( void ) const;\n",$types{$type},$methFldName;
    $methFldName = "";

}

print "\n\n";
print "  ostream & printFieldNames( ostream & dest );\n";
print "  friend ostream & operator<<( ostream & dest, const $className & rec);\n\n";
print "protected: \n\n";
print "private: \n\n";
print "  static FieldInfo Fields[];\n\n";
print "  $className( const $className & copyFrom );\n";
print "  $className & operator=( const $className & assignFrom );\n\n";
print "};\n\n";

print "//\n";
print "// Inline methods\n";
print "//\n\n";

print "inline\n";
print "$className::$className( char * rawRec )\n";
print "  : BitPackNet( rawRec ) \n";
print "{\n";
print "  return;\n";
print "}\n\n";

    
    
seek( INPUT, 0, 0);


while(<INPUT>)
{

    chop;
    
    ($name, $len, $type) = split(/ +/);

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

    print "inline $types{$type}\n";
    print "$className::get$methFldName( void ) const\n";
    print "{\n";

    if( $type ne "STRING" && $type ne "ESTRING" )
    {
	print "  return( $meth{$type}( Fields[ $UpperName].getStart(), \n";
	print "                       Fields[ $UpperName ].getLen() ) );\n";
    }
    else
    {
	print "  return( $meth{$type}( Fields[ $UpperName].getStart() ) ); \n";
    }
	
    print "}\n\n";

    $methFldName = "";

}




#!/usr/local/bin/perl


($className, $ext) = split(/\./,$ARGV[0] );

open( INPUT, "<$ARGV[0]" );

print "ostream & \n";
print "$className::printFieldNames( ostream & dest )\n";
print "{\n";
print "  for( int i = 0; Fields[i].getName() != 0; i++ )";
print "    {\n";
print "       dest << Fields[i].getName() << ' ';\n";
print "    }\n";
print "  return( dest );\n";
print "}\n\n";

print "ostream & \n";
print "operator<<( ostream & dest, const $className & rec )\n";
print "{\n\n";
print "   Tbcd digit;\n";
print "   dest ";

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

    #
    # this is a switch statement
    #

  TYPES: {

      if( $type eq "STRING" )
      {				
	  
	  for( $i = 0; $i < ($len / 8); $i++ )
	  {
	      print "<< rec.get$methFldName()[$i]\n        ";
	  }
	  print "<< ' '\n        ";

	  last TYPES;
      }

      if( $type eq "ESTRING" )
      {
	  for( $i = 0; $i < ($len / 8); $i++ )
	  {
	      print "<< E2A( rec.get$methFldName()[$i] )\n        ";
	  }
	  print "<< ' '\n        ";

	  last TYPES;
      }

      if( $type eq "TBCD" )
      {
	  print "<< digit.getChar( rec.get$methFldName() ) << ' '\n        ";
	  last TYPES;
      }
	  
      print "<< rec.get$methFldName() << ' '\n        ";
  }
    
    
    
    $methFldName = "";
    
}

print ";\n\n";
print "}\n\n";


	    
    
    

    

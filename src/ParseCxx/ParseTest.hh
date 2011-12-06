#ifndef _ParseTest_hh_
#define _ParseTest_hh_
/**
   File:        ParseTest.hh
   Project:	DocTools (%PP%)
   Item:	%PI% (%PF%)
   Desc:        
  
    C++ header file for testing ParseCxx Perl Module.
  
   Notes:
  
   Quick Start: - short example of class usage
  
   Author:      Paul Houghton - (paul4hough@gmail.com)
   Created:     02/26/01 04:57
  
   Revision History: (See end of file for Revision Log)
  
    Last Mod By:    %PO%
    Last Mod:	    %PRT%
    Version:	    %PIV%
    Status:	    %PS%
  
    %PID%
**/

#include <DocToolsConfig.hh>
#include <DumpInfo.hh>
#include <iostream>

#if defined( DOCTOOLS_DEBUG )
#define inline
#endif


class ParseTest
{

public:

  ParseTest( void );

  virtual ~ParseTest( void );

  virtual ostream &	    write( ostream & dest ) const;
  virtual istream &	    read( istream & src );

  virtual ostream &	    toStream( ostream & dest ) const;
  virtual istream &	    fromStream( istream & src );

  virtual bool	    	good( void ) const;
  virtual const char * 	error( void ) const;
  virtual const char *	getClassName( void ) const;
  virtual const char *  getVersion( bool withPrjVer = true ) const;
  virtual ostream &     dumpInfo( ostream &	dest = cerr,
				  const char *  prefix = "    ",
                                  bool          showVer = true ) const;

  inline DumpInfo< ParseTest >
  dump( const char * preifx = "    ", bool showVer = true ) const;

  static const ClassVersion version;

protected:

private:

  ParseTest( const ParseTest & from );
  ParseTest & operator =( const ParseTest & from );

};

#if !defined( inline )
#include <ParseTest.ii>
#else
#undef inline

ostream &
operator << ( ostream & dest, const ParseTest & src );

istream &
operator >> ( istream & src, const ParseTest & dest );


#endif


/**
   Detail Documentation
  
    Data Types: - data types defined by this header
  
    	ParseTest	class
  
    Constructors:
  
    	ParseTest( );
  
    Destructors:
  
    Public Interface:
  
  	virtual ostream &
  	write( ostream & dest ) const;
  	    write the data for this class in binary form to the ostream.
  
  	virtual istream &
  	read( istream & src );
  	    read the data in binary form from the istream. It is
  	    assumed it stream is correctly posistioned and the data
  	    was written to the istream with 'write( ostream & )'
  
  	virtual ostream &
  	toStream( ostream & dest ) const;
  	    output class as a string to dest (used by operator <<)
  
  	virtual istream &
  	fromStream( istream & src );
  	    Set this class be reading a string representation from
  	    src. Returns src.
  
    	virtual Bool
    	good( void ) const;
    	    Return true if there are no detected errors associated
    	    with this class, otherwise false.
  
    	virtual const char *
    	error( void ) const;
    	    Return a string description of the state of the class.
  
    	virtual const char *
    	getClassName( void ) const;
    	    Return the name of this class (i.e. ParseTest )
  
    	virtual const char *
    	getVersion( bool withPrjVer = true ) const;
    	    Return the version string of this class.
  
	virtual ostream &
	dumpInfo( ostream &	dest = cerr,
		  const char *  prefix = "    ",
		  bool          showVer = true ) const;
  	    output detail info to dest. Includes instance variable
  	    values, state info & version info.
  
  	static const ClassVersion version
  	    Class and project version information. (see ClassVersion.hh)
  
    Protected Interface:
  
    Private Methods:
  
    Associated Functions:
  
    	ostream &
    	operator <<( ostream & dest, const ParseTest & src );
  
  	istream &
  	operator >> ( istream & src, ParseTest & dest );
  
   Example:
  
   See Also:
  
   Files:
  
   Documented Ver:
  
   Tested Ver:
  
   Revision Log:
  
   %PL%
**/

// Set XEmacs mode
//
// Local Variables:
// mode: c++
// End:
//
#endif // ! def _ParseTest_hh_ 


# db3.pl -- routines to read dBaseIII-files
# (c) 1992 Paul Bijnens
#
# Newsgroups: comp.lang.perl
# From: ntools1@be.oracle.com (student1)
# Subject: Re: read DBF3 files
# Sender: usenet@oracle.us.oracle.com (Oracle News Poster)
# Organization: Oracle University
# Date: Mon, 20 Dec 1993 19:02:59 GMT
#
#  Louis> Hello, Where can I find a script for transform DBF3 file into
#  Louis> a tab or coma file?
#
#  Louis> Merci !
#
# Below, you find the solution.  The most important bug is that
# the documentation is hidden in the source code.  :-)
# (mail me on "pbijnens@be.oracle.com", if you need help with it.)
#
#
# This is a shell archive (produced by shar 3.49)
# To extract the files from this archive, save it to a file, remove
# everything above the "!/bin/sh" line above, and type "sh file_name".
#
# made 09/25/1993 10:38 UTC by polleke@triton
#
# $Id$
#
# $Log$
# Revision 2.1  1995/11/16 14:33:07  houghton
# Initial Version.
#
#
 
package db3;


# initialise db3-structures from header of the file
# usage: db3init(FH);
sub main'db3init {
    local(*Db3) = shift(@_);
    local($rec, $pos);

    seek(Db3, 0, 0);
    read(Db3, $rec, 32);
    $db3version = &endian(substr($rec,0,1));
    $db3totrec  = &endian(substr($rec,4,4));
    $db3lenhead = &endian(substr($rec,8,2)) - 1;
    $db3lenrec  = &endian(substr($rec,10,2));

    if ($db3version == 0x83) {
       warn("Cannot handle memo-fields\n");
    } elsif ($db3version != 0x03) {
       warn("Not a db3-file\n");
       return 0;
    }

    $db3nf = $[;
    $db3fmt = "a1";
    for ($pos = 32; $pos < $db3lenhead; $pos += 32) {
       read(Db3, $rec, 32);
       $db3fn[$db3nf] = unpack("A11", $rec);
       $db3fn[$db3nf] =~ s/\000.*//;   # sometimes trailing garbage!!!
       $db3ft[$db3nf] = substr($rec,11,1);
       $db3fl[$db3nf] = &endian(substr($rec,16,2));
       $db3fi{$db3fn[$db3nf]} = $db3nf;        # name -> field index
       $db3fmt .= "A$db3fl[$db3nf]";
       #if ($db3ft[$db3nf] eq "C") {
       #    $db3fmt .= "a$db3fl[$db3nf]";
       #} elsif ($db3ft[$db3nf] eq "N") {
       #    $db3fmt .= "A$db3fl[$db3nf]";
       #}
       $db3nf++;
    }

    if (($c = getc(Db3)) != "\r") {
       print "Header korrupt...\n";
    }
    1;
}


# read the next record in the db3-file
# usage:  db3read(FH)
# return: list of fields, or () on eof or error;
sub main'db3read {
    local(*Db3) = shift(@_);
    local($rec, $del, @res);

    do {
       read(Db3, $rec, $db3lenrec)  ||  return ();
       ($del, @res) = unpack($db3fmt, $rec);
    } while ($del ne " ");
    return @res;
}


# print db3-record in flatfile-record format
# usage: db3_flat_str
sub main'db3_flat_str {
    local($,) = "\t";
    local($\) = "\n";

    print @db3fn;
    print @db3fl;
    print @db3ft;
}


# convert to flatfile-like database
# usage: db3_flat(DBHANDLE)
sub main'db3_flat {
    local(*Db3) = shift(@_);
    local($,) = "\t";
    local($\) = "\n";
    local(@flds);

    while (@flds = &main'db3read(*Db3)) {
       print @flds;
    }
}


# convert little-endian to native machine order
# (intel = big-endian  ->  mc68k = big-endian)
# usage
sub endian
{
    local($n) = 0;
    foreach (reverse(split('', $_[0]))) {
       $n = $n * 256 + ord;
    }
    $n;
}

1;

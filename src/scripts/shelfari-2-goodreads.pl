#!/usr/bin/perl
# 2016-01-29 (cc) <paul4hough@gmail.com>
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use Text::CSV;

my $csv = new Text::CSV({ binary => 1});

open( my $fh, "<", $ARGV[0] ) || die($ARGV[0]);
my $flds = $csv->getline($fh);

my @hdr = ($flds->[0],
	   $flds->[11],
	   $flds->[2],
	   "Average Rating",
	   $flds->[3],
	   $flds->[4],
	   $flds->[5],
	   $flds->[6],
	   "Original Publication Year",
	   $flds->[7],
	   $flds->[8],
	   $flds->[9],
	   $flds->[10],
    );
$csv->combine(@hdr);
print $csv->string(),"\n";

while(my $row = $csv->getline($fh) ) {
    my @rec = ($row->[0],
	       $row->[11],
	       $row->[2],
	       "",
	       $row->[3],
	       $row->[4],
	       $row->[5],
	       $row->[6],
	       "",
	       $row->[7],
	       $row->[8],
	       $row->[9],
	       $row->[10],
	);

    $csv->combine(@rec);
    print $csv->string(),"\n";
}

#Title, Author, ISBN, My Rating, Average Rating, Publisher, Binding, Year Published, Original Publication Year, Date Read, Date Added, Bookshelves, My Review

#while(my $row = $csv->getline($fh) )


#use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
#use File::Find;
#use MP4::File;
#use Meta::TMDb;
#use Meta::IMDB;
#use Term::ReadLine;
#use Data::Dumper;
#use POSIX;
#use Text::CSV;
#use DVD::Read;
#use Encode;
#use LWP;
#use MP4::Info;
#use XML::Parser;
#use Imager;

#my $dbh = DBI->connect('dsn','user','pass',
#                       { RaiseError => 1, AutoCommit => 0 } );
#

## Local Variables:
## mode:perl
## end:

#!/usr/bin/perl
# 2016-03-16 (cc) <paul@pahoughton.net>
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;

foreach my $fn (@ARGV) {
  if( $fn =~ /1975 Melvin E Sine Yearbook Pg (\d\d)/ ) {
    my $num = $1;
    ++ $num;
    my $nfn = sprintf("1976-05-30 01%02d%02d melvin-sine-yearbook-pg-%02d.jpg",
		      $num / 60,$num % 60,$num);
    rename("$fn", "$nfn") || die( "rn $fn $!");
  }
}

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

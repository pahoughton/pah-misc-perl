#!/usr/bin/perl
# 2015-11-16 (cc) <paul4hough@gmail.com>
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use Carp;
use File::Basename;

my $Songs;

while(<>) {
    if( /^#/ ) {
	next;
    }
    chop;
    my $album = basename(dirname($_));
    my $artist = basename(dirname(dirname($_)));
    my $fn = basename($_);
    $fn =~ s~^[0-9- ]+(.*)....$~$1~;
    my $s =  "$artist~$album~$fn";
    if( ! defined( $Songs->{$s} ) ) {

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

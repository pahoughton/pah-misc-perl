#!/usr/bin/perl
# 2015-05-22 (cc)paul4hough@gmail.com

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
#use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
use File::Find;
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

our $fdir = (@ARGV > 0 ? $ARGV[0] : ".");

our $mfsdir = "/Volumes/MediaHFS/media/audio";

my $tracks;

sub foreachfn {

    # if ( -f $_ && /_...$/ ) {
    # 	printf("%s\n",$File::Find::name);
    # }
    if ( /^(\d\d-\d\d)\s/ ) {
	my $k = "$File::Find::dir/$1";
	if( ! defined( $tracks->{$k} ) ) {
	    $tracks->{$k} = $File::Find::name;
	} else {
	    printf( "dup: %s\n     %s\n",$tracks->{$k},$File::Find::name);
	    #exit 2;
	}
    }
}

find( \&foreachfn, $fdir );


foreach my $k (keys(%$tracks)) {
    print "t: ".$tracks->{$k}."\n";
    exit;
}

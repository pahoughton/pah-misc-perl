#!/usr/bin/perl
# 2015-07-06 (cc) <paul4hough@gmail.com>
# copy all the files in a m3u to some dest dir

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
#use DBI;
#use DBD::Pg qw(:pg_types);
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Copy;
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

#my $dbh = DBI->connect($dsn,$db_user,$db_pass,
#                       { RaiseError => 1, AutoCommit => 0 } );
#

#print join('~',@ARGV)."\n";

my $dest = shift(@ARGV);
#print "dest--".join('~',@ARGV)."\n";
#exit;
if( ! -d $dest ) {
    die "dest $dest not a dir.";
}

while(<>) {
    if (/^\s*#/ ) {
	next;
    }
    chop;
    if( /.*(album.*)/ ) {
	my $destfn = $1;
	my $destdir = "$dest/".dirname($destfn);
	my $srcfn = "/home/paul/Music/$destfn";
	my $destpath = "$dest/$destfn";
	if( ! -f $destpath ) {
	    print "cp $srcfn\n   $destpath\n";
	    make_path($destdir);
	    copy( $srcfn, $destpath ) || print("ERROR $srcfn - $!");
	}
    }
}

## Local Variables:
## mode:perl
## end:

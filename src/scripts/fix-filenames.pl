#!/usr/bin/perl
# 2016-11-19 (cc) <paul@pahoughton.net>
#
# rename files with ' &'"(){}[] to '-'
eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use File::Find;

sub found {
  if ( ! -f || ! /[ &\(\){}]/ ) {
    return;
  }
  my $ofn = $_;
  my $nfn = $ofn;
  $nfn =~ y/ /-/;
  $nfn =~ y/'/-/;
  $nfn =~ y/"/-/;
  $nfn =~ y/()[]{}/-/;
  $nfn =~ s~-&-~-~g;
  $nfn =~ s~,-~-~g;
  $nfn =~ s~--~-~g;
  $nfn =~ s~-\.~.~g;
  $nfn =~ s~\.-~.~g;
  print join("\n","  $_","--$nfn",'');
  rename( $_, $nfn ) || die( "mv '$_' '$nfn' - $?")
}

find( {wanted => \&found, follow => 1 },'/srv/media/image');

#use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
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

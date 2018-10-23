#!/usr/bin/env perl
# 2017-12-14 (cc) <paul4hough@gmail.com>
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use strict;
use warnings;
use Data::Dumper;
use JSON;

my %hist;

my $jtext = do {
  my $fn = "20170211/YouTube/history/watch-history.json";

   open(my $json_fh, "<", $fn )
      or die("Can't open $fn: $!\n");
   local $/;
   <$json_fh>
};

my $json = JSON->new;
my $jdata = $json->decode($jtext);
foreach my $vid (@$jdata) {
  my $t = $vid->{snippet}->{title};
  if( $hist{$t} ) {
    # print "duph:$t\n";
  } else {
    print "$t\n";
    $hist{$t} = 1;
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

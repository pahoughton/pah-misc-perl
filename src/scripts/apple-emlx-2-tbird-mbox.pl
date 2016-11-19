#!/usr/bin/perl
# 2016-03-14 (cc) <paul@pahoughton.net>
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use File::Find;
use Date::Parse;

my %boxCnt;

sub appendmbox($$) {
  my ($mbox,$fn) = @_;
  open (my $fh, "<$fn") || error ("open < $fn: $!");
  local $/ = undef;  # read entire file
  my $body = <$fh>;
  close($fh);

  my ($length, $xml);

  $body =~ m/^(\d+)\s*\n(.*)$/s || error ("$fn: unparsable length");
  ($length, $body) = ($1, $2);

  $xml = substr ($body, $length) || error ("$fn: unparsable body");
  $body = substr ($body, 0, $length);

  $xml =~ m/^<\?xml version/ || error ("$fn: misparsed body");

  my %props;
  my @chunks = split (/<key>/i, $xml);
  shift @chunks;
  foreach (@chunks) {
    my ($key, $val) = m@^(.*?)</key>\s*(.*)$@s;
    $val =~ s@\</dict>.*$@@s;
    $val =~ s@^\s*<([^<>]+)>\s*(.*)\s*</\1>\s*$@$2@s;
    $props{$key} = $val;
  }

  my $headers;
  $body =~ m/^(.*?\n)\n(.*)$/s || error ("$fn: unparsable headers");
  ($headers, $body) = ($1, $2);

  $body =~ s/\s+$//s;

  if ($headers !~ m/^From /s) {
    my ($date) = ($headers =~ m/^Date\s*:\s*(.+?)\n/mi);
    if( ! defined($date) ) {
      $date = '';#die("\n--\n$fn\n--$headers\n--\n$body");
    }
    $headers = "From - $date\n$headers";
  }

  $body =~ s/^(From )/>$1/gm;   # mangle
  open(my $ofh, ">>",$mbox) || die("open $mbox: $!");
  print $ofh "$headers\n$body\n\n";
  close($ofh);
}

sub found {
  if( /emlx$/ ) {
    my $boxpath = $File::Find::name;
    $boxpath =~ s~/home.*Mailboxes/~~;
    $boxpath =~ s~mbox/[^/]+/Data/.*emlx*~mbox/~;
    $boxpath =~ s~\.mbox/$~~;
    $boxpath =~ s~\.mbox/~-~g;
    $boxpath =~ s~\s+~~g;
    #$boxpath =~ s~/?(\S.*)\.mbox/~$1-=-~g;
    if( defined( $boxCnt{$boxpath} ) ) {
      ++ $boxCnt{$boxpath};
    } else {
      $boxCnt{$boxpath} = 1;
      print "$boxpath\n";
    }
    appendmbox( "/home/paul/cmac.mail/mboxes/$boxpath-mbox", $File::Find::name );
  }
}

find( \&found, @ARGV );

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

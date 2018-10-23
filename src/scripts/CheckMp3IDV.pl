#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP3::Tag;

sub wanted {
  my $fn = $_;
  my $fp = $File::Find::name;
  if( /.mp3$/ ) {
    my $tags = MP3::Tag->new( $fn );
    if( ! $tags ) {
      die "No tags: $fp";
    }
    my @found = $tags->get_tags();
    if( exists $tags->{ID3v2} ) {
      if( exists $tags->{ID3v1 } ) {
	# print "BOTH: $fp\n";
      }
    } elsif( exists $tags->{ ID3v1 } ) {
      print "---1: $fp\n";
    }
  }
}

find( \&wanted, "." );

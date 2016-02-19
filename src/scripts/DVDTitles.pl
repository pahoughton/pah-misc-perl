#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Find;
use File::Basename;
use DVD::Read;

foreach my $fn (@ARGV) {
  my $dvd = DVD::Read->new( $fn );

  my $title_1_dur;
  my $longest_dur = 0;
  my $longest_title = 0;

  print "Title Lengths for: $fn (",$dvd->titles_count,")\n";
  foreach my $n (1 .. $dvd->titles_count ) {
    my $title = $dvd->get_title( $n );
    if( $title ) {
      printf( "  %02d  %5d\n",$n,$title->length );

      if( $n == 1 ) {
	$title_1_dur = $title->length;
      }
      if( $title->length > $longest_dur ) {
	$longest_title = $n;
	$longest_dur = $title->length;
      }
    }
  }
  my $d = $longest_dur / 1000;

  my ($s,$m,$hr);
  $s = $d % 60;
  $m = $d % (60*60) / 60;
  $hr = $d / (60*60);


  my $chaps = $dvd->title_chapters_count( $longest_title );
  
  printf( "Longest Title: %d - %02d:%02d:%02d (%d) Chapters: %d\n",
	  $longest_title,
	  $hr,$m,$s,
	  $longest_dur,
	  $chaps );
}


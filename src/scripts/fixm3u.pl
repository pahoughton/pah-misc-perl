#!/usr/bin/perl
# 2015-06-14 (cc) <paul4hough@gmail.com>

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;

my $mis = 0;
my $fnd = 0;
my $hld = <>;

while( <> ) {
    if( /^#/ ) {
	$hld .= $_;
	next;
    }

    s~/Volumes/SMKMedia/Media/Audio/Digital/Album~/Users/paul/Public/media/audio/album~;
    s~/Volumes/SMKMedia/Media/Audio/CD/Album~/Users/paul/Public/media/audio/album~;
    s~/Volumes/SMKMedia/PersMedia/Audio/Digital/Album~/Users/paul/Public/media/audio/album~;
    s~/Volumes/SMKMedia/PersMedia/Audio/CD/Album~/Users/paul/Public/media/audio/album~;

    s~The Best Of Smooth Jazz, Vol. 1~The Best of Smooth Jazz, Vol_ 1~;
    s~The Best Of Smooth Jazz, Vol. 2~The Best of Smooth Jazz, Vol_ 2~i;
    s~The Best Of Smooth Jazz, Vol. 3~The Best of Smooth Jazz, Vol_ 3~i;
    s~The Best of Smooth Jazz, Vol. 4_ For Lovers~The Best of Smooth Jazz, Vol_ 4_ For Lovers~;

    s~Gord's Gold, Vol. 2~Gord's Gold, Vol_ 2~;
    s~All Time Greatest Hits, Vol. 1~All Time Greatest Hits, Vol_ 1~;
    s~01-07 Love Potion No. 9~01-07 Love Potion No_ 9~;
    s~01-05 Woods Behind St. Andrews~01-05 Woods Behind St_ Andrews~;

    chop;
    if( ! -f $_ ) {
	#print "$_\n";
	++ $mis;
    } else {
	print "$hld$_\n";
	++ $fnd;
    }
    $hld = '';
}

print "f: $fnd ; m: $mis\n";

## mode:perl

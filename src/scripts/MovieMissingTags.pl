#!/opt/local/bin/perl -w

eval 'exec /opt/local/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use warnings;
use strict;
use File::Basename;
use File::Find;
use MP4::File;
use MP4::Info;

sub wanted {

  if( -f && $File::Find::name =~ /(.*).mp4$/ ) {

    my $tag = get_mp4tag($_);
    if( $tag && $tag->{NAM} && $tag->{YEAR} ) {
      return;
    } else {
      print $File::Find::name,"\n";
    }
  }
}

find( \&wanted, "." );

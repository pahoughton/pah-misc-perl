#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;

use Image::ExifTool;

my $srcdir = "/mnt/Data/Pictures/Archives/1970/1972 Paul A Houghton";

foreach my $fn (@ARGV) {
  my $srcExif = new Image::ExifTool;
  my $srcTags = $srcExif->ImageInfo($fn);

  if( ! defined( $srcTags->{ ObjectName } ) ) {
    print "exiftool -overwrite_original -tagsFromFile \"$srcdir/$fn\" --Comment \"$fn\"\n";
  }
}



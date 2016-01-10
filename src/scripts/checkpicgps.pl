#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;

use Image::ExifTool;

my $city="Glendale";
my $state="AZ";
my $location="5047 W Belmont";

foreach my $fn (@ARGV) {
  my $srcExif = new Image::ExifTool;
  my $srcTags = $srcExif->ImageInfo($fn);

  if( ! defined( $srcTags->{ GPSLongitude } ) ) {
    my $loc = "";
    if( defined( $srcTags->{ Location } ) ) {
      $loc .= $srcTags->{ Location };
    }
    if( defined( $srcTags->{ City } ) ) {
      $loc .= ", " . $srcTags->{ City };
    }
    if( defined( $srcTags->{ 'Province-State' } ) ) {
      $loc .= ", " . $srcTags->{ 'Province-State' };
    }

    print "$loc $fn\n";
  }
}



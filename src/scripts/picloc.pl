#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;

use Image::ExifTool;

my $city="Glendale";
my $state="AZ";
my $location="5047 W Belmont";

while( <> ) {
  chop;
  my $srcExif = new Image::ExifTool;
  my $srcTags = $srcExif->ImageInfo($_);

  print $srcTags->{ Location },", ",
    $srcTags->{ City }, ", ",
      $srcTags->{ 'Province-State' }, ", ",
      "\n";

#   my $exifTool = new Image::ExifTool;
#   $exifTool->SetNewValue( 'Caption-Abstract',$sub );
#   $exifTool->SetNewValue( Keywords => 'Houghton', AddValue => 1 );
#   $exifTool->SetNewValue( 'DateTimeOriginal', $dt );
#   $exifTool->SetNewValue( 'City', $city );
#   $exifTool->SetNewValue( 'Province-State', $st );
#   if( $loc ) {
#     $exifTool->SetNewValue( 'Location', $loc );
#   }
#   if( $evt ) {
#     $exifTool->SetNewValue( 'Event', $evt );
#   }

#   my $dst_fn = "$dt.jpg";

#   my $src_fn = "../1950 Houghton Family/$fn.JPG";

#   $exifTool->WriteInfo( $src_fn, $dst_fn );
}



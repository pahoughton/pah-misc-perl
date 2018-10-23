#!/usr/bin/perl -w

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell

use strict;

use DBI;
use File::Basename;
use Audio::DB::Parse::ReadFiles;
use Audio::DB::Schema;
use Audio::DB;
use Term::ReadLine;


my $adb = Audio::DB->new( -adaptor => "dbi::mysql",
			  -user    => "paul",
			  -pass    => "mysql",
			  -dsn     => "music" );
my $mdb = $adb->adaptor()->dbh();

my %sids = ( 128 => "./Alan Jackson Feat. Jimmy Buffett/Greatest Hits Volume II_ Alan Jackson/17 It's Five O' Clock Somewhere.mp4",
	     5281 => "./Baby Bash Ft T-Pain/Cyclone/02 Cyclone.mp4",
	     5287 => "./Beyonce/B'Day Delux Edition/01 Beautiful Liar.mp4",
5292 => "./Beyonce Ft Voltio/B'Day/02 Get Me Bodied (Timbaland Remix).mp4",
5307 => "./Bobby Valentino/Special Occasion/02 Anonymous (Ft Timbaland).mp4",
5331 => "./Britney Spears/Blackout/02 Piece Of Me (orig).mp4",
5331 => "./Britney Spears/Blackout/02 Piece Of Me (remix).mp4",
5573 => "./Chris Brown/Exclusive/02 Kiss Kiss (Ft T-Pain).mp4",
5860 => "./Eagles/Hotel California/03 Life In The Fast Lane.mp4",
1507 => "./Eric Clapton/Slowhand/01 Cocaine.mp4",
5449 => "./Faith Evans/The Fast and the Furious (Soundtrack)/01 Good Life (Ft Ja Rule, Vita, Caddillac Tah).mp4",
5452 => "./Fat Joe/The Elephant in the Room/07 I Wont Tell (Ft J. Holiday).mp4",
5454 => "./Fergie/The Dutchess/01 Fergalicious.mp4",
5515 => "./Janet Jackson/Feedback - Single/01 Feedback.mp4",
5557 => "./John Cougar Mellencamp/The Lonesome Jubilee/05 Cherry Bomb.mp4",
5560 => "./John Mayer/Continuum (Special Edition)/01 Waiting On The World To Change.mp4",
5613 => "./Kelly Rowland/Ms. Kelly_ Diva Deluxe/01 Daylight.mp4",
5633 => "./Lenny Kravitz/Austin Powers_ The Spy Who Shagged Me Soundtrack/04 American Woman.mp4",
5687 => "./Morris Day And The Time/Ice Cream Castle`/04 Jungle Love.mp4",
5695 => "./Natasha Bedingfield/Pocketful Of Sunshine/04 Love Like This (feat. Sean Kingston).mp4",
5709 => "./Nickelback/All The Right Reasons/05 Savin Me.mp4",
3148 => "./Olivia Newton-John/Back To Basics_ The Essential Collection 1971-1992/06 Physical.mp4",
3159 => "./OneRepublic/Dreaming Out Loud (Bonus Track Version)/04 Apologize.mp4",
5722 => "./Pat Green/Cannonball/05 Feels Just Like It Should_1.mp4",
5758 => "./Rihanna/Good Girl Gone Bad/01 Umbrella.mp4",
5760 => "./Rihanna/Good Girl Gone Bad/06 Hate That I Love You (Ft Ne-Yo).mp4",
5776 => "./Santana/Ultimate Santana/01 Into The Night (Ft Chad Kroeger).mp4",
5777 => "./Sara Bareilles/Little Voice/01 Love Song (live).mp4",
3686 => "./Shooter Jennings/Electric Rodeo/02 Gone To Carolina.mp4",
5809 => "./Soulja Boy Tell'em/Souljaboytellem.com/02 Crank That (Soulja Boy).mp4",
3887 => "./Stevie Wonder/Talking Book/06 Superstition.mp4",
5827 => "./Sugar Ray Ft Super Cat/Floored/04 Fly.mp4",
5833 => "./T-Pain Ft Yung Joc/Epiphany/12 Buy You A Drank.mp4",
5846 => "./Terri Clark/Greatest Hits 1994-2004_ Terri Clark/12 Girls Lie Too.mp4",
5854 => "./The D.E.Y_/The D.E.Y. Has Come/01 Give You The World.mp4",
5279 => "./Toby Keith/Pull My Chain/01 I'm Just Talking About Tonight.mp4",
4314 => "./Toby Keith/Unleashed/01 Courtesy Of The Red, White & Blue.mp4",
4318 => "./Toby Keith/Unleashed/05 Beer For My Horses Ft Willie Nelson.mp4",
5927 => "./Tyra B/Singles/01 Givin' Me a Rush.mp4",
5958 => "./Wyclef Jean Ft Akon/Carnival, Vol II_ Memoirs Of An Immigrant/17 Sweetest Girl.mp4",
5964 => "./Zion Ft Akon/The Perfect Melody/03 The Way She Moves.mp4"
	   );

foreach my $sid (keys(%sids)) {
  #print "$artist, $album, $song\n";
  my $sql = "select title, album, genre, album_artist, artist, track, year from tracks
where song_id = $sid";
  
  my $sth = $mdb->prepare( $sql );
  $sth->execute() || die( $sql );
  my ($s,$l,$g,$aa,$a,$t,$y) = $sth->fetchrow_array();
  if( $g ) {
    my $ainfo;
    if( $aa ne $a ) {
      $ainfo = "-R \"$aa\" -a \"$a\"";
    } else {
      $ainfo = "-a \"$a\"";
    }
    print "mp4tags -s \"$s\" -A \"$l\" $ainfo -y $y -t $t -g \"$g\" \"",
      $sids{ $sid },"\"\n";
  } else {
    print "# NOT FOUND: $sid\n";
  }
}

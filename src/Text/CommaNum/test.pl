# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 4 };
use Text::CommaNum;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $v;
$v = Text::CommaNum::CommaNum( 23 );
ok( $v eq "23" );

$v = Text::CommaNum::CommaNum( 12345.73 );
ok( $v eq "12,345.73" );

$v = Text::CommaNum::CommaNum( 12345236643 );
ok( $v eq "12,345,236,643" );

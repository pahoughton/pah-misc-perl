# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Log.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('Log') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

{
  my $log_fn = 'LogTest.log';

  if( -f $log_fn ) {
    unlink( $log_fn );
  }
  my $log = new Log( 'log-file' => $log_fn );

  ok( defined( $log ) );
  ok( -f $log_fn );

  $log->info( "info message" );
  $log->error( "error msg" );

  ok( 2 );
}

# Local Variables:
# mode:perl
# End:

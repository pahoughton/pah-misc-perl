#!/usr/bin/perl
# See: http://wiki.nginx.org/SimpleCGI
#   first checing in original source.

eval 'exec perl -W $0 ${1+"$@"}'
    if 0 ;

use English;
use FCGI;
use Socket;
use Getopt::Long;
use FCGI::ProcManager;
sub shutdown { FCGI::CloseSocket($socket); exit; }
sub restart  { FCGI::CloseSocket($socket); &main; }
use sigtrap 'handler', \&shutdown, 'normal-signals';
use sigtrap 'handler', \&restart,  'HUP';
require 'syscall.ph';
use POSIX qw(setsid);
use strict;
use warnings;

END()   { }
#BEGIN() { }
#{
#  no warnings;
#  *CORE::GLOBAL::exit = sub { die "fakeexit\nrc=" . shift() . "\n"; };
#};
 
#eval q{exit};
#if ($@) {
#  exit unless $@ =~ /^fakeexit/;
#}

our $optSockFn = "/var/run/nginx/cigwrap-dispatch.sock";
our $optNumProcesses = 5;
our $optHelp = 0;

our $socket = undef;
our $proc_manager = undef;
our $request = undef;
our %req_params;

sub Usage () {
  print $PROGRAM_NAME." -s socketfn -p numchildren\n";
}

&main;

sub daemonize() {
  chdir '/' or die "Can't chdir to /: $!";
  defined( my $pid = fork ) or die "Can't fork: $!";
  exit if $pid;
  setsid() or die "Can't start a new session: $!";
  # umask 0;
}
 
sub main {
  my $optRet = GetOptions( "socket=s" => \$optSockFn,
			   "processes=i" => \$optNumProcesses,
			   "help" => \$optHelp);

  if( ! $optRet ) {
    die "get opt failed";
  }
  if( $optHelp ) {
    Usage();
    exit(2);
  }
  # we want groupw rw on the socket
  umask(0007);
  
  $proc_manager = FCGI::ProcManager->new( {n_processes => $optNumProcesses} );
  print "OPT SOCK: ".$optSockFn."\n";
  $socket = FCGI::OpenSocket( $optSockFn, 10 )
  ; #use UNIX sockets - user running this script must have w access to the 'nginx' folder!!
  $request =
  FCGI::Request( \*STDIN, \*STDOUT, \*STDERR, \%req_params, $socket,
  &FCGI::FAIL_ACCEPT_ON_INTR );
  $proc_manager->pm_manage();
  if ($request) { request_loop() }
  FCGI::CloseSocket($socket);
}
 
sub request_loop {
  while ( $request->Accept() >= 0 ) {
    $proc_manager->pm_pre_dispatch();
 
    #processing any STDIN input from WebServer (for CGI-POST actions)
    my $stdin_passthrough = '';
    my $req_len = undef;
    { no warnings; $req_len = 0 + $req_params{'CONTENT_LENGTH'}; };
    if ( ( $req_params{'REQUEST_METHOD'} eq 'POST' ) && ( $req_len != 0 ) ) {
      my $bytes_read = 0;
      while ( $bytes_read < $req_len ) {
        my $data = '';
        my $bytes = read( STDIN, $data, ( $req_len - $bytes_read ) );
        last if ( $bytes == 0 || !defined($bytes) );
        $stdin_passthrough .= $data;
        $bytes_read += $bytes;
      }
    }
 
    #running the cgi app
    if (
	( -x $req_params{SCRIPT_FILENAME} ) &&    #can I execute this?
	( -s $req_params{SCRIPT_FILENAME} ) &&    #Is this file empty?
	( -r $req_params{SCRIPT_FILENAME} )       #can I read this file?
       ) {
      pipe( CHILD_RD,   PARENT_WR );
      pipe( PARENT_ERR, CHILD_ERR );
      my $pid = open( CHILD_O, "-|" );
      unless ( defined($pid) ) {
        print("Content-type: text/plain\r\n\r\n");
        print "Error: CGI app returned no output - Executing $req_params{SCRIPT_FILENAME} failed !\n";
        next;
      }
      my $oldfh = select(PARENT_ERR);
      $|     = 1;
      select(CHILD_O);
      $| = 1;
      select($oldfh);
      if ( $pid > 0 ) {
        close(CHILD_RD);
        close(CHILD_ERR);
        print PARENT_WR $stdin_passthrough;
        close(PARENT_WR);
        my $rin = my $rout = my $ein = my $eout = '';
        vec( $rin, fileno(CHILD_O),    1 ) = 1;
        vec( $rin, fileno(PARENT_ERR), 1 ) = 1;
        $ein    = $rin;
        my $nfound = 0;
	
        while ( $nfound = select( $rout = $rin, undef, $ein = $eout, 10 ) ) {
          die "$!" unless $nfound != -1;
          my $r1 = vec( $rout, fileno(PARENT_ERR), 1 ) == 1;
          my $r2 = vec( $rout, fileno(CHILD_O),    1 ) == 1;
          my $e1 = vec( $eout, fileno(PARENT_ERR), 1 ) == 1;
          my $e2 = vec( $eout, fileno(CHILD_O),    1 ) == 1;
	  
          if ($r1) {
	    my $errbytes;
	    my $bytes;
            while ( $bytes = read( PARENT_ERR, $errbytes, 4096 ) ) {
              print STDERR $errbytes;
            }
            if ($!) {
              my $err = $!;
              die $!;
              vec( $rin, fileno(PARENT_ERR), 1 ) = 0
		unless ( $err == POSIX::EINTR or $err == POSIX::EAGAIN );
            }
          }
          if ($r2) {
	    my $bytes = undef;
	    my $s;
            while ( $bytes = read( CHILD_O, $s, 4096 ) ) {
              print $s;
            }
            if ( !defined($bytes) ) {
              my $err = $!;
              die $!;
              vec( $rin, fileno(CHILD_O), 1 ) = 0
		unless ( $err == POSIX::EINTR or $err == POSIX::EAGAIN );
            }
          }
          last if ( $e1 || $e2 );
        }
        close CHILD_RD;
        close PARENT_ERR;
        waitpid( $pid, 0 );
      } else {
        foreach my $key ( keys %req_params ) {
          $ENV{$key} = $req_params{$key};
        }
 
        # cd to the script's local directory
        if ( $req_params{SCRIPT_FILENAME} =~ /^(.*)\/[^\/] +$/ ) {
          chdir $1; 
        }
        close(PARENT_WR);
        #close(PARENT_ERR);
        close(STDIN);
        close(STDERR);
	
        #fcntl(CHILD_RD, F_DUPFD, 0);
        syscall( &SYS_dup2, fileno(CHILD_RD),  0 );
        syscall( &SYS_dup2, fileno(CHILD_ERR), 2 );
	
        #open(STDIN, "<&CHILD_RD");
        exec( $req_params{SCRIPT_FILENAME} );
        die("exec failed");
      }
    } else {
      print("Content-type: text/plain\r\n\r\n");
      print "Error: No such CGI app - $req_params{SCRIPT_FILENAME} may not exist or is not executable by this process.\n";
    }
  }
}

package Log;

use 5.008005;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Log ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


our @App_Options =
 (
  [ "log-file=s",	undef,
			"FILE",	    "opt",
			"log file name",
			"name of the file to write log messages to" ],
  [ "log-replace",	undef,
			"",	    "opt",
			"replace current log file",
			"The log file is normally appended. When"
			." this flag is given, it will be overwritten" ],
  [ "log-level=s",	"INFO|ERROR|WARN",
			"LEVEL",    "opt",
			"output log levels (INFO|DEBUG|ERROR)",
			"The log levels to write to the log file" ],
  [ "log-tee",		undef,
			"",	    "opt",
			"tee log output to stderr",
			"All log messages written to the log file"
			." will also be written to STDERR." ]
 );

# Preloaded methods go here.

use IO::File;
use IO::Handle;
use File::Basename;
use Carp;

sub new ($%) {
  my ($this, %params) = @_;

  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;

  $$self{ log_mode } = "w+";
  $$self{ log_tee } = 0;
  $$self{ log_level } = "INFO,ERROR,WARN";

  foreach my $p (keys(%params)) {

    if( $p eq 'log-file' ) {
      $$self{ log_file_name } = $params{ $p };

    } elsif( $p eq 'log-replace' ) {
      $$self{ log_mode } = "w";

    } elsif( $p eq 'log-tee' ) {
      $$self{ log_tee } = 1;

    } elsif( $p eq 'log-level' ) {
      $$self{ log_level } = $params{ $p };
    }
  }

  if( exists( $params{ 'OPTIONS' } ) ) {
    my $opts = $params{ 'OPTIONS' };
    if( $opts->opt( 'log-file' ) ) {
      $$self{ log_file_name } = $opts->opt( 'log-file' );

    } elsif( $opts->opt( 'log-level' ) ) {
      if( $opts->opt( 'log-level' ) =~ /^\+/ ) {
	$$self{ log_level } .= $opts->opt( 'log-level' );
      } else {
	$$self{ log_level } = $opts->opt( 'log-level' );
      }
    } elsif( $opts->opt( 'log-tee' ) ) {
      $$self{ log_tee } = 1;

    } elsif( $opts->opt( 'log-replace' ) ) {
      $$self{ log_mode } = "w";
    }
  }

  if( exists( $$self{ log_file_name } ) ) {
    $$self{ log } = new IO::File( $$self{ log_file_name },
				     $$self{ log_mode } );
    defined( $$self{ log } )
      || croak( "open ".$$self{ log_file_name } );

  } else {
    $$self{ log } = new IO::Handle;
    $$self{ log }->fdopen(fileno(STDOUT),"w")
      || croak "open STDOUT???";
  }

  $$self{ log_level } =~ tr/a-z/A-Z/;

  return( $self );
}

sub info ($@) {
  my ($self, @rest) = (@_);

  my ($pkg, $fn, $ln) = caller;
  if( $fn =~ /(.*) \(autosplit [^\)]+\)/ ) {
    $fn = $1;
  }
  $fn = basename( $fn );

  $self->_logit( "INFO", $fn, $ln, @rest );
}

sub error ($@) {
  my ($self, @rest) = (@_);

  my ($pkg, $fn, $ln) = caller;
  if( $fn =~ /(.*) \(autosplit [^\)]+\)/ ) {
    $fn = $1;
  }
  $fn = basename( $fn );

  $self->_logit( "ERROR", $fn, $ln, @rest );
}

sub _logit ($$@) {
  my ($self, $level, $fn, $ln, @rest) = (@_);

  if( $$self{ log_level } =~ /$level/ ) {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)
      = localtime(time);
    my $time_stamp = sprintf( "%04d-%02d-%02d %02d:%02d:%02d",
			      1900 + $year,
			      $mon + 1,
			      $mday,
			      $hour,
			      $min,
			      $sec );
    $$self{ log }->print( "$time_stamp $level $fn:$ln " );
    $$self{ log }->printf( @rest );

    if( $$self{ log_tee } ) {
      print STDERR "$time_stamp $level $fn:$ln ";
      printf STDERR @rest;
    }
  }
			
}
# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Log - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Log;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Log, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Paul Houghton 719-527-7834, E<lt>houghton@mcilink.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Paul Houghton 719-527-7834

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut



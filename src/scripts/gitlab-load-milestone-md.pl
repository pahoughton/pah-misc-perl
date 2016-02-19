#!/usr/bin/perl
# 2015-10-26 (cc) <paul4hough@gmail.com>
#
# create gitlab milestones and issues from a simple markdown file
#
# see milestones.md for example
#
# config file: ~/.gitlab-plcfg
# http://gitlab"
# myprivatetoken
#

eval 'exec perl -w -S $0 ${1+"$@"}'
    if 0 ;

use warnings;
use strict;
use Carp;
use File::HomeDir;
use GitLab::API::v3;
use Data::Dumper;

my $cfgfn = File::HomeDir->my_home()."/.gitlab-plcfg";

open( my $cfgfh, "<", $cfgfn )
    || die("open $cfgfn $?");

my $gitlab_url = <$cfgfh>;
chop $gitlab_url;
$gitlab_url =~ s~/*\s*$~~;
$gitlab_url .= "/api/v3";
my $gitlab_tok = <$cfgfh>;
chop $gitlab_tok;
$gitlab_tok =~ s~\s+$~~;
close($cfgfh);

print "Using GitLab:$gitlab_url\n";
my $glab = new GitLab::API::v3(url => $gitlab_url, token => $gitlab_tok )
    || die("new gitlab $gitlab_url:$gitlab_tok: $?");



my $state;
my $prj;
my $prjdesc = '';
my $desc;
my @milelist; # for order
my $milestones;
my $curmile;
my $curisu;
my @isulist = (); # for order
my $inquote = 0;



while(<>) {
    if( $inquote ) {
	$desc .= $_;
	if( /^```/ ) {
	    $inquote = 0;
	}
    } elsif( /^```/ ) {
	$desc .= $_;
	$inquote = 1;
    } elsif( ! $prj && /^\#\#+\s+(\S+)\s+milestones/ ) {
	$prj = $1;

    } elsif( /^[\*\-]\s+(\S.*)/ ) {
	if( $curmile ) {
	    if( $state eq 'mile' ) {
		$milestones->{$curmile}->{desc} = $desc;
	    } else {
		my @mileisus = @isulist;
		$milestones->{$curmile}->{isulist} = \@mileisus;
		my $inum = @mileisus;
		--$inum;
		$milestones->{$curmile}->{isudesc}->{$inum} = $desc;
	    }
	    @isulist = ();
	} else {
	    $prjdesc = $desc;
	}
	$curmile = $1;
	push(@milelist,$curmile);
	$state = 'mile';
	$desc = '';
    } elsif( /^\s+-\s+(\S.*)/ ) {
	if( $state eq 'mile' ) {
	    $milestones->{$curmile}->{desc} = $desc;
	} else {
	    my $inum = @isulist;
	    --$inum;
	    $milestones->{$curmile}->{isudesc}->{$inum} = $desc;
	}

	$curisu = $1;
	push(@isulist,$curisu);
	$state = 'isu';
	$desc = '';
    } else {
	#print "ELSE:$_\n";
	s~^\s+~~;
	$desc .= $_;

    }
}
if( $state eq 'isu' ) {
    my $inum = @isulist;
    --$inum;
    $milestones->{$curmile}->{isudesc}->{$inum} = $desc;
    $milestones->{$curmile}->{isulist} = \@isulist;
    $inum = 0;
} else {
    $milestones->{$curmile}->{desc} = $desc;
}

print "Results:\n";
print "prj:$prj:desc\n$prjdesc\n";

my $gprj = $glab->project($prj);
# print Dumper($gprj);

# my $prjid =
foreach my $m (@milelist) {
    my $mdesc = $milestones->{$m}->{desc};
    my $inum = 0;

    my $gmil = $glab->create_milestone($prj,
				       { title => $m,
					 description => $mdesc });
    # ugg does not return milestone id :(
    my $mid;
    my $gpmiles = $glab->milestones($prj);
    foreach my $tm (@$gpmiles) {
	if( $tm->{title} eq $m ) {
	    $mid = $tm->{id};
	    last;
	}
    }
    if( ! defined( $mid ) ) {
	die("mid not found for $m\n");
    }
    print "mile:$m:$mid:desc\n$mdesc\n";
    my $milist = $milestones->{$m}->{isulist};
#    print "issues:\n",join("\n",@$milist),"\n";
    foreach my $i (@$milist) {
	my $idesc = $milestones->{$m}->{isudesc}->{$inum};

	$glab->create_issue($prj,
			    { title => $i,
			      milestone_id => $mid,
			      description => $idesc,
			    });
	print "isu:$i:$inum:desc\n$idesc\n";
	++ $inum;
    }
}





#use DBI;
#use DBD::Pg qw(:pg_types);
#use File::Basename;
#use File::Find;
#use MP4::File;
#use Meta::TMDb;
#use Meta::IMDB;
#use Term::ReadLine;
#use Data::Dumper;
#use POSIX;
#use Text::CSV;
#use DVD::Read;
#use Encode;
#use LWP;
#use MP4::Info;
#use XML::Parser;
#use Imager;

#my $dbh = DBI->connect('dsn','user','pass',
#                       { RaiseError => 1, AutoCommit => 0 } );
#

## Local Variables:
## mode:perl
## end:

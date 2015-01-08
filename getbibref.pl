#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use Getopt::Long;

my $replace = 0;

unless (GetOptions('replace' =>	\$replace))  {
	print "Usage: \$0 [--replace] URLS\n";
	exit 10;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

htmlfetch::setupw();

nextarg:
for my $arg (@ARGV) {
    my %revurl;
    $str = htmlfetch::locfetch($arg);
    $urls = GetUrls::parsestr($str);
    my $revurls = htmlfetch::urlreverse($urls);
    my $bt = $revurls->{'Bibtex entry for this abstract'};
    unless (defined $bt)  {
	print "No bibtex entry found for $arg\n";
	next;
    }
    $btrstr = htmlfetch::htmlfetch($bt);

    $ref = bibref::parsestr($btrstr);
    unless ($ref)  {
	print "Couldn't	parse reference	in $arg\n";
	next;
    }

    if ($replace)  {
	if ($ref->replaceref($dbase))  {
		print "Inserted	$arg as	$ref->{ident}\n"
	}
    }
    else {
	my $id = $ref->{ident};
	my $suff = 0;
	my $nid	= $id;
	while  (my $existref = bibref::readref($dbase,	$nid)) {
		if ($existref->{adsurl} eq $arg)  {
			print "Already got $arg as $nid\n";
			next nextarg;	
		}
		if ($suff == 0)	 {
			$suff =	ord('a');
		}
		elsif ($suff >=	ord('z'))  {
			$suff =	ord('A');
		}
		else {
			$suff++;
		}
		$nid = $id . chr($suff);
	}
	$ref->{ident} =	$nid;
	if ($ref->insertref($dbase)) {
		print "Inserted	$arg as	$ref->{ident}\n";
	}
    }
}

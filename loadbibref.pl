#! /usr/bin/env dfperl

use bibref;
use dbaccess;
use Getopt::Long;

my $replace = 0;

unless (GetOptions('replace' =>	\$replace))  {
	print "Usage: \$0 [--replace] URLS\n";
	exit 10;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

while (<STDIN>) {
	chop;
	last if /\s*\@\w+\{[^,]+,/;
}

push @lines, $_;
while (<STDIN>) {
	chop;
	push @lines, $_	unless /^\s*$/;
	last if	/^\s*\}\s*$/;
}

my $r =	bibref::parsearr(\@lines);
unless  ($r)  {
	print "Could not parse bibref\n";
	exit 10;
}

if ($replace)  {
    if ($r->replaceref($dbase))  {
	   print "Inserted $r->{ident}\n";
	   exit 0;
    }
    else  {
	   print "Could not insert reference $r->{ident}\n";
	   exit 20;
    }
}

my $id = $r->{ident};
my $suff = 0;
my $nid	= $id;

while  (my $existref = bibref::readref($dbase,	$nid)) {
    if ($existref->{title} eq $r->{title})  {
		print "Already got bibref as $nid\n";
		exit 0;	
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

$r->{ident} =	$nid;
if ($r->insertref($dbase)) {
	print "Inserted $r->{ident}\n";
}
else  {
	print "Could not insert reference $r->{ident}\n";
	exit 20;
}

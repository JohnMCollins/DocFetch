#! /usr/bin/env dfperl

use dbaccess;
use bibref;

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$reflist = bibref::readrefs($dbase);

for my $ref (@$reflist)	 {
	next if	defined	$ref->{adsurl} or $ref->{type} eq 'book';
	print "$ref->{ident}: $ref->{title}\n";
}

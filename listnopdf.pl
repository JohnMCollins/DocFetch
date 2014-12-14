#! /usr/bin/env dfperl

use dbaccess;
use bibref;
use pdf;

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$reflist = bibref::readrefs($dbase);

for my $ref (@$reflist)	 {
	next if	$ref->{type} eq	'book';
	next if	pdf::haspdf($dbase, $ref->{ident});
	print "$ref->{ident}: $ref->{adsurl}\n";
}

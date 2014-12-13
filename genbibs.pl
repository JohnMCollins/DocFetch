#! /usr/bin/perl

use dbaccess;
use bibref;

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$reflist = bibref::readrefs($dbase);

$donesome = 0;

for my $ref (@$reflist)  {
	print "\n" if $donesome > 0;
	$donesome++;
	print $ref->genref,"\n";
}

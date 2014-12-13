#! /usr/bin/perl

use dbaccess;
use bibref;

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$errors = 0;
for my $arg (@ARGV) {
	$arg = lc $arg;
	my $ref = bibref::readref($dbase, $arg);
	if ($ref) {
		$ref->delref($dbase);
	}
	else {
		print "Couldn't find $arg\n";
		$errors++;
	}
}

exit 10 if $errors > 0;


#! /usr/bin/env dfperl

use bibref;
use dbaccess;
use pdf;

unless ($#ARGV == 1) {
	print "Usage: $0 ident source-file\n";
	exit 10;
}

$ident = shift @ARGV;
$sourcefile = shift @ARGV;

unless (-f $sourcefile)  {
	print "Cannot find $sourcefile\n";
	exit 11;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

unless (open(SRC, $sourcefile))  {
	print "Cannot open $sourcefile\n";
	exit 12;
}

$source = "";
while (sysread(SRC,$next,4096) > 0)  {
	$source .= $next;
}
close SRC;

unless	(pdf::putsource($dbase, $ident, $source))  {
	print "Failed to write source\n";
	exit 14;
}


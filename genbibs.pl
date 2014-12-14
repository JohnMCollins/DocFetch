#! /usr/bin/env dfperl

use dbaccess;
use bibref;
use Getopt::Long;
use fileexp;

my $outfile	= "\$HOME/lib/bibrefs.bib";
GetOptions("outfile=s" => \$outfile) or	die "Usage: $0 [-outfile file ]\n";

unless ($outfile eq '-')  {
	$outfile = fileexp::fileexp($outfile);
	die "Cannot open $outfile\n" unless open(OUTF, ">$outfile");
	select OUTF;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$reflist = bibref::readrefs($dbase);

$donesome = 0;

for my $ref (@$reflist)	 {
	print "\n" if $donesome	> 0;
	$donesome++;
	print $ref->genref,"\n";
}


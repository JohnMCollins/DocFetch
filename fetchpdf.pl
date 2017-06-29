#! /usr/bin/env dfperl

use Getopt::Long;
use bibref;
use dbaccess;
use pdf;
use fileexp;

my $dir	= "";
my $delafter = 3600;
GetOptions("directory=s" => \$dir, 'delafter=i' =>\$delafter) or die "Usage: $0 [-dir dirname ] idents\n";

if (length($dir) != 0)	{
	$dir = fileexp::fileexp($dir);
	chdir $dir or die "Invalid directory $dir\n";
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$errors	= 0;

my @okwritten;

for my $arg (@ARGV) {
	my $ref	= bibref::readref($dbase, $arg);
	unless	($ref)	{
		print "Unknown ident $arg\n";
		$errors++;
		next;
	}
	unless	(pdf::haspdf($dbase, $arg))  {
		print "$arg doesn't have a PDF\n";
		$errors++;
		next;
	}
	my $pdf	= pdf::getpdf($dbase, $arg);
	unless	($pdf)	{
		print "Could not read PDF for $arg\n";
		$errors++;
		next;
	}
	my $outfname = $arg . '.pdf';
	unless	(open(OUTF, ">$outfname"))  {
		print "Could not create	output file for	$arg\n";
		$errors++;
		next;
	}
	my $nbytes = length $pdf;
	my $offs = 0;
	while ($nbytes > 0)  {
		my $nout = 4096;
		$nout =	$nbytes	if $nout > $nbytes;
		my $nput = syswrite OUTF, $pdf,	$nout, $offs;
		$offs += $nput;
		$nbytes	-= $nput;
	}
	close OUTF;
	push @okwritten, $outfname;
}

if ($delafter > 0  &&  $#okwritten >= 0  &&  fork == 0)  {
    sleep $delafter;
    unlink @okwritten;
    exit 0;
}

if ($errors > 0)  {
	print "There were $errors errors\n";
	exit 20;
}
exit 0;


#! /usr/bin/env dfperl

use bibref;
use dbaccess;
use pdf;

unless ($#ARGV == 1 or $#ARGV == 2) {
	print "Usage: $0 [-f] ident pdf-file\n";
	exit 10;
}

$force = 0;
$ident = shift @ARGV;
if ($ident eq '-f') {
    $force = 1;
    $ident = shift @ARGV;
}
$pdffile = shift @ARGV;

unless ($pdffile)  {
    print "No PDF file given\n";
    exit 10;
}

unless (-f $pdffile)  {
	print "Cannot find $pdffile\n";
	exit 11;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

if (!$force and pdf::haspdf($dbase,	$ident))  {
	print "$ident already has a PDF\n";
	exit 13;
}

unless (open(PDF, $pdffile))  {
	print "Cannot open $pdffile\n";
	exit 12;
}

$pdf = "";
while (sysread(PDF,$next,4096) > 0)  {
	$pdf .=	$next;
}
close PDF;

unless	(pdf::putpdf($dbase, $ident, $pdf))  {
	print "Failed to write PDF\n";
	exit 14;
}


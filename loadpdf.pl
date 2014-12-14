#! /usr/bin/perl

use bibref;
use dbaccess;
use pdf;

unless ($#ARGV == 1) {
	print "Usage: $0 ident pdf-file\n";
	exit 10;
}

$ident = shift @ARGV;
$pdffile = shift @ARGV;

unless (-f $pdffile)  {
	print "Cannot find $pdffile\n";
	exit 11;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

if (pdf::haspdf($dbase,	$ident))  {
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


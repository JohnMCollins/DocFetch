#! /usr/bin/env dfperl

use bibref;
use dbaccess;
use pdf;
use Getopt::Long;

my $replace = 0;
my $final = 0;
my $draft = 0;
my $back = 1;
my $remove = 0;

unless  (GetOptions('replace' => \$replace, 'final' => \$final, 'draft' => \$draft, 'back=i' => \$back, 'delete' => \$remove))  {
	print "Usage: $0 [--fianl] [--draft] [--back=n] [--delete] [ident] pdf-file\n";
	exit 10;
}

my $ident;
my $pdffile = shift @ARGV;
if  (@ARGV)  {
    $ident = $pdffile;
    $pdffile = shift @ARGV;
}

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

unless (defined $ident)  {
    $ident = dbaccess::getlastident $dbase, $back;
    unless (defined $ident)  {
        print "Records do not go back $back\n";
        exit 15;
    }
}

unless  ($final || $draft) {
    my $year = dbaccess::getyear($dbase, $ident);
    my $def = $year < 2015? 'y':'n';
    print "Final version ($def)? ";
    my $ans = <STDIN>;
    chop $ans;
    $ans = lc $ans;
    if ($ans =~ /^([yn])/)  {
        $final = $1 eq 'y';
    }
    else {
        $final = $def eq 'y';
    }
    $final = $final? 1: 0;
}

unless  ($replace)  {
    my $stat = pdf::haspdf($dbase, $ident);
    if  ($stat > 1)  {
        print "$ident already has a final PDF\n";
        exit 13;
    }
    unless  ($stat == 0 || $final)  {
	   print "$ident already has a PDF\n";
	   exit 13;
    }
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

unless	(pdf::putpdf($dbase, $ident, $pdf, $final))  {
	print "Failed to write PDF\n";
	exit 14;
}

print "PDF added to $ident OK\n";
unlink $pdffile if $remove;
exit 0;

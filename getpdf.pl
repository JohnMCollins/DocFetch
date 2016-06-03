#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use Getopt::Long;
use HTML::Entities;
use pdf;

my $replace = 0;

unless (GetOptions('replace' =>	\$replace))  {
	print "Usage: \$0 [--replace] URLS\n";
	exit 10;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

htmlfetch::setupw();

$errors	= 0;

for my $arg (@ARGV) {
    my $ref	= bibref::readref($dbase, $arg);
    unless ($ref)  {
        print "Cannot find $arg\n";
	   $errors++;
	   next;
    }
    unless (defined	$ref->{adsurl})	 {
	   print "No URL on $arg\n";
	   $errors++;
	   next;
    }
    if (!$replace && pdf::haspdf($dbase, $arg))	{
	   print "$arg already has a pdf\n";
	   $errors++;
	   next;
    }
    my $str = htmlfetch::locfetch($ref->{adsurl});
    my $urls = GetUrls::parsestr($str);
    my $revurl = htmlfetch::urlreverse($urls);
    #my $ep = $revurl->{'Full Refereed Journal Article (PDF/Postscript)'};
    #if (defined $ep)  {
    #    $pdf = htmlfetch::locfetch(decode_entities($pdflink));
    #}
    #else  {
        my $ep = $revurl->{'arXiv e-print'};
        unless (defined $ep) {
    	   print "Could not find arXiv print for $arg\n";
    	   $errors++;
	       next;
        }
        $epstr = htmlfetch::locfetch($ep);
        $urls = GetUrls::parsestr($epstr);
        $revurl = htmlfetch::urlreverse($urls);
        $pdflink = $revurl->{'PDF'} || $revurl->{'PDF only'};
        unless ($pdflink)	 {
	       print "Could not find PDF link for $arg\n";
	       $errors++;
            next;
        }
        $pdf = htmlfetch::locfetch($pdflink);
    }
    unless  (pdf::putpdf($dbase, $arg, $pdf))  {
	   print "Failed to write PDF\n";
	   $errors++;
	   next;
    }
#}

if ($errors > 0)  {
    print "There were $errors errors\n";
    exit 20;
}
exit 0;

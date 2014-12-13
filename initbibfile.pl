#! /usr/bin/perl

use bibref;
use dbaccess;
use Getopt::Long;

my $replace = 0;

unless (GetOptions('replace' => \$replace))  {
	print "Usage: \$0 [--replace] file ...\n";
	exit 10;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

for my $arg (@ARGV) {
	unless (open(INP, $arg))  {
		print "Cannot open file $arg\n";
		next;
	}
	my $reflist = bibref::parsefile(\*INP);
	print "Got ", $#$reflist, " references from $arg\n";
	
	for my $ref (@$reflist)  {
		if ($replace)  {
    		if ($ref->replaceref($dbase))  {
    			print "Inserted $ref->{ident}\n"
    		}
    	}
    	else {
    		my $id = $ref->{ident};
    		my $suff = 0;
    		my $nid = $id;
    		while  (bibref::readref($dbase, $nid)) {
    			if ($suff == 0)  {
    				$suff = ord('a');
    			}
    			elsif ($suff >= ord('z'))  {
    				$suff = ord('A');
    			}
    			else {
    				$suff++;
    			}
    			$nid = $id . chr($suff);
    		}
    		$ref->{ident} = $nid;
    		if ($ref->insertref($dbase)) {
    			print "Inserted $ref->{ident}\n";
    		}
    	}
	}
}

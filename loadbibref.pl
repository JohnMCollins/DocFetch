#! /usr/bin/env dfperl

use bibref;
use dbaccess;

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

while (<STDIN>) {
	chop;
	last if /\s*\@\w+\{[^,]+,/;
}

push @lines, $_;
while (<STDIN>) {
	chop;
	push @lines, $_	unless /^\s*$/;
	last if	/^\s*\}\s*$/;
}

my $r =	bibref::parsearr(\@lines);
unless  ($r)  {
	print "Could not parse bibref\n";
	exit 10;
}

if ($r->replaceref($dbase))  {
	print "Inserted $r->{ident}\n";
	exit 0;
}
else  {
	print "Could not insert reference $r->{ident}\n";
	exit 20;
}
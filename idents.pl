#! /usr/bin/env dfperl

use dbaccess;

$dbase = dbaccess::connectdb;
$sfh = $dbase->prepare("SELECT ident FROM item ORDER BY ident");
$sfh->execute;
while (my $row = $sfh->fetchrow_array()) {
	print "$row\n";
}

exit 0;


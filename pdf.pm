package	pdf;
use strict;
use Carp;
use dbaccess;

sub haspdf ($$)	{
	my $dbase = shift;
	my $ident = shift;
	my $qid	= $dbase->quote($ident);
	my $query = "SELECT pdf	is not null from item where ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_arrayref;
	return 0 unless	$row;
	$row->[0] != 0;
}

sub getpdf ($$)	{
	my $dbase = shift;
	my $ident = shift;
	my $qid	= $dbase->quote($ident);
	my $query = "SELECT pdf	FROM item WHERE	ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_arrayref;
	return undef unless $row;
	$row->[0];
}

sub putpdf ($$$) {
	my $dbase = shift;
	my $ident = shift;
	my $pdf	= shift;
	my $qid	= $dbase->quote($ident);
	my $query = "UPDATE item SET pdf=? WHERE ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute($pdf);
}

sub putsource ($$$) {
        my $dbase = shift;
	my $ident = shift;
	my $source= shift;
	my $qid	= $dbase->quote($ident);
	my $query = "UPDATE item SET source=? WHERE ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute($source);
}

1;


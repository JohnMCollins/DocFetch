package	pdf;
use strict;
use Carp;
use dbaccess;

# Return 0 if ident doesn't have a PDF
# Return 1 if it has but isn't final ref-approved version
# Return 2 if it has and it is final

sub haspdf ($$)	{
	my $dbase = shift;
	my $ident = shift;
	my $qid	= $dbase->quote($ident);
	my $query = "SELECT pdf	is not null,final from item where ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_arrayref;
	return 0 unless	$row;
	my $hp = $row->[0];
	return 0 unless $hp != 0;
	my $fn = $row->[1];
	return 1 if $fn == 0;
	return 2;
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

sub hassource ($$)	{
	my $dbase = shift;
	my $ident = shift;
	my $qid	= $dbase->quote($ident);
	my $query = "SELECT source	is not null from item where ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_arrayref;
	return 0 unless	$row;
	$row->[0] != 0;
}

sub getsource ($$)	{
	my $dbase = shift;
	my $ident = shift;
	my $qid	= $dbase->quote($ident);
	my $query = "SELECT source FROM item WHERE ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_arrayref;
	return undef unless $row;
	$row->[0];
}

sub putpdf ($$$;$) {
	my $dbase = shift;
	my $ident = shift;
	my $pdf	= shift;
	my $final = shift;
	$final = 0 unless defined $final;
	my $qid	= $dbase->quote($ident);
	my $query = "UPDATE item SET final=$final,pdf=? WHERE ident=$qid";
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


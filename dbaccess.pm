package	dbaccess;
use strict;
use Carp;
use DBI;

our @Itemfields;

sub connectdb {
	my $dbase = DBI->connect("DBI:mysql:database=papers;host=nancy.toad.me.uk", "papupd", "PaperHacker");
	croak "Cannot open database" unless $dbase;
	$dbase;
}

sub getitemfields ($) {
	my $dbase = shift;
	my $sfh	= $dbase->prepare("DESCRIBE item");
	my @DBfields;
	$sfh->execute;
	while (my $row = $sfh->fetchrow_hashref())  {
		my $fn = $row->{Field};
		push @DBfields,	$fn if $fn ne 'pdf' and	$fn ne 'ident';
	}
	@DBfields = sort @DBfields;
	unshift	@DBfields, 'ident';
	@DBfields;
}

1;

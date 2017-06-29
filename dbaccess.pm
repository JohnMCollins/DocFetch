package	dbaccess;
use strict;
use Carp;
use DBI;

our %Omitfields = (ident => 1, pdf => 1, source => 1);
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
		push @DBfields,	$fn unless defined $Omitfields{$fn};
	}
	@DBfields = sort @DBfields;
	unshift	@DBfields, 'ident';
	@DBfields;
}

sub getlastident ($;$) {
    my $dbase = shift;
    my $n = shift;
    $n = 1 unless defined $n;
    my $sfh = $dbase->prepare("SELECT ident FROM item ORDER BY seq DESC LIMIT $n");
    $sfh->execute;
    my $row;
    while ($n > 0  &&  ($row = $sfh->fetchrow_arrayref()))  {
        $n--;
    }
    return  undef unless defined $row;
    return  $row->[0];
}

1;

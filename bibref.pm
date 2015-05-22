package	bibref;
use strict;
use Carp;
use dbaccess;

sub new	{
	my $this = {};
	bless $this;
}

sub copyhash ($) {
	my $result = shift;
	bless $result;
	$result;
}

sub parseauthor	($$) {
	my $author = shift;
	my $year = shift;

	$year =	localtime[5] unless $year;
	$year %= 100;

	# Elide	accent chars in	author name

	$author	=~ s/\{?\\["'`~]([aeioun])\}?/$1/g;

	# Now extract first {}ed name

	$author	=~ s/\n/ /gm;
	$author	=~ s/^[^\{]*\{+([^}]+)(\}+.*)$/$1/;
	$author	=~ s/\s+//g;
	$author	= lc $author;
	$author	. sprintf "%.2d", $year;
}

sub parsearr {
	my $arr	= shift;
	my %kws;
	my $hadend = 0;
	my $line = shift @$arr;

	return undef unless $line =~ /^\s*\@(\w+)\{([^,]+),/;

	my $type = lc $1;
	my $ident = $2;

	while (@$arr)  {
		$line =	shift @$arr;
		last if	$hadend	|| $line =~ /^\s*\}\s*$/;
		next unless $line =~ /^\s*(\w+)\s*=\s*(.*[^,])(,?)\s*$/;
		my $keyw = $1;
		my $data = $2;
		my $comma = $3;
		while ($comma ne ',')  {
			return undef unless $#$arr >= 0;
			my $next = shift @$arr;
			if ($next =~ /^\s*\}\s*$/) {
				$hadend	= 1;
				last;
			}
			my $nbit;
			($nbit,	$comma)	= $next	=~ /^\s*(.*[^,])(,?)\s*$/;
			$data .= ' ' . $nbit;
		}
		$data =~ s/\s{2,}/ /g;
		$data =~ s/^"(.*)"$/$1/;
		$data =~ s/^\{(.*)\}$/$1/;
		$kws{$keyw} = $data;
	}

	$ident = parseauthor($kws{author}, $kws{year}) unless $ident =~	/^[a-zA-Z]+\d+$/;
	$kws{type} = $type;
	$kws{ident} = $ident;
	copyhash(\%kws);
}

sub parsefile ($) {
	my $fl = shift;
	my @results;
	my @lines;

	while (<$fl>) {
		chop;
		next unless /\s*\@\w+\{[^,]+,/;
		push @lines, $_;
		while (<$fl>) {
			chop;
			push @lines, $_	unless /^\s*$/;
			last if	/^\s*\}\s*$/;
		}
		my $r =	parsearr(\@lines);
		push @results, $r if $r;
		@lines = ();
	}
	\@results;
}

sub parsestr ($) {
	my $str	= shift;
	my @parts = split(/\r?\n/, $str);
	while (@parts)	{
		my $line = $parts[0];
		last if	$line =~ /^\s*\@/;
		shift @parts;
	}
	parsearr(\@parts);
}

# Do special things with these

our %skipkws = (author => 1, title => 1, type => 1, ident => 1);
our %nobrack = (year =>	1, volume => 1);
our %noquote = (year =>	1);

our @DBfields =	();

sub initDBfields ($) {
	return if $#DBfields >=	0;
	my $dbase = shift;
	@DBfields = dbaccess::getitemfields($dbase);
}

sub readref ($$) {
	my $dbase = shift;
	my $id = shift;
	my $qid	= $dbase->quote($id);
	my $query = "SELECT " .	join(',', @DBfields) . " FROM item WHERE ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	my $row	= $sfh->fetchrow_hashref;
	return undef unless $row;
	bless $row;
	$row;
}

sub readrefs ($) {
	my $dbase = shift;
	my @results;
	my $query = "SELECT " .	join(',', @DBfields) . " FROM item ORDER BY ident";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
	while (my $row = $sfh->fetchrow_hashref)  {
		bless $row;
		push @results, $row;
	}
	\@results;
}

sub insertorreplaceref ($$$)  {
	my $this = shift;
	my $dbase = shift;
	my $op = shift;
	my @flist;
	my @vlist;
	for my $k (@DBfields) {
		next unless defined($this->{$k});
		push @flist, $k;
		if (defined $noquote{$k})  {
			push @vlist, $this->{$k};
		}
		else {
			push @vlist, $dbase->quote($this->{$k});
		}
	}
	my $query = "$op INTO item (" .	join(',', @flist) . ") VALUES (" . join(',', @vlist) . ")";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
}

sub insertref ($$)  {
	my $this = shift;
	my $dbase = shift;
	$this->insertorreplaceref($dbase, 'INSERT');
}

sub replaceref ($$) {
	my $this = shift;
	my $dbase = shift;
	$this->insertorreplaceref($dbase, 'REPLACE');
}

sub delref ($$)	{
	my $this = shift;
	my $dbase = shift;
	croak "No ID in	ref given to delref" unless defined($this->{ident});
	my $qid	= $dbase->quote($this->{ident});
	my $query = "DELETE FROM item WHERE ident=$qid";
	my $sfh	= $dbase->prepare($query);
	$sfh->execute;
}

# Generate a nice string

sub genref {
	my $this = shift;
	my $result = "\@$this->{type}\{$this->{ident},\n";
	$result	.= "   author =	\{$this->{author}\},\n";
	$result	.= "	title =	\"\{$this->{title}\}\"";
	for my $kw (sort keys %$this) {
		next if	defined	$skipkws{$kw} or length($this->{$kw}) == 0;
		$result	.= ",\n";
		$result	.= ' ' x (9 - length($kw));
		$result	.= "$kw	= ";
		if (defined($noquote{$kw})) {
			$result	.= $this->{$kw};
		}
		elsif (defined($nobrack{$kw}))	{
			$result	.= "\"$this->{$kw}\"";
		}
		else {
			$result	.= "\{$this->{$kw}\}";
		}
	}
	$result	. "\n\}";
}

1;

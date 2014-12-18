#! /usr/bin/env dfperl

@OK1 = ();
@OK2 = ();
@Problems1 = ();
@Problesm2 = ();
for my $arg (@ARGV) {
	my $res = `Getbib "$arg"`;
	chop $res;
	if ($res =~ /^Inserted.*as\s+(\w+)$/)  {
		push @OK1, [$1, $arg];
	}
	else {
		push @Problems1, $arg;
	}
}

for my $refs (@OK1) {
	my ($ref, $arg) = @$refs;
	if (system("Getpdf $ref 2>/dev/null") == 0)  {
		push @OK2, $refs;
	}
	else {
		push @Problesm2, $refs;
	}
}

for my $p1 (@Problems1)  {
	print "Could not load bibref for $p1\n";
}

for my $refs (@Problems2) {
	my ($ref, $arg) = @$refs;
	print "Could not load PDF for $arg loaded as bibref $ref\n";
}

for my $refs (@OK2) {
	my ($ref, $arg) = @$refs;
	print "$arg loaded OK as $ref\n";
}

system("Updbib") if $#OK2 >= 0;

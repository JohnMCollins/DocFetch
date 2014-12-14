package	fileexp;
use Carp;
use strict;

sub fileexp {
	my $fname = shift;

	if ($fname =~ m|^~([^/]*)/|)  {
		my $user = $1;
		my $dir;
		if (length($user) == 0)	 {
			$dir = $ENV{'HOME'};
		}
		else {
			my @pbits = getpwnam($user);
			croak "Unknown user ~$user in file name	$fname\n" unless @pbits;
			$dir = $pbits[7];
		}
		$fname =~ s|^~[^/]*|$dir|;
	}
	$fname =~ s/\$(\w+)/$ENV{$1}/g;
	$fname;
}

1;


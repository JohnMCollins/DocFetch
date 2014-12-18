# Fetch	an HTML	file as	a string using CURL lin

package	htmlfetch;

use strict;
use warnings;
use WWW::Curl::Easy;
use dfconfig;

our $Username;
our $Passwd;
our $Cookiefile;
our $Lastplace;

sub setupw {
	my $dfc = dfconfig->new();
	$dfc->loadfile();
	$Username = $dfc->{username};
	$Passwd	= $dfc->{password};
	$Cookiefile = $dfc->{cookiefile};
}

sub htmlfetch {
	my $url	= shift;
	my $curl = new WWW::Curl::Easy;

	# Parse	out location if	supplied, otherwise put	last one in front

	if ($url =~ m|^(https?://[^/]+)/|)  {
		$Lastplace = $1;
	}
	else  {
		$url = $Lastplace . $url;
	}

	# Include header

	$curl->setopt(CURLOPT_HEADER,1);
	$curl->setopt(CURLOPT_USERPWD, "$Username:$Passwd") if defined($Username) and defined($Passwd);
	$curl->setopt(CURLOPT_URL, $url);
	$curl->setopt(CURLOPT_USERAGENT, "FetcharXiv");
    $curl->setopt(CURLOPT_COOKIEFILE, $Cookiefile);
	my $response_body;
	open(my	$fileb,	">", \$response_body);
	$curl->setopt(CURLOPT_WRITEDATA, $fileb);
	my $retcode = $curl->perform;
	return	$response_body if $retcode == 0;
	print STDERR "An error happened	with $url: ".$curl->strerror($retcode)." ($retcode)\n";
	"";
}

sub locfetch {
	my $url	= shift;
	my $str	= htmlfetch($url);
	while ($str =~ /^Location:\s*(.*)$/m) {
		$url = $1;
		$str = htmlfetch($url);
	}
	$str;
}

sub urlreverse {
	my $urls = shift;
	my %revurl;
	for	my $k (keys %$urls) {
		$revurl{$urls->{$k}} = $k;
    }
    \%revurl;
}

1;


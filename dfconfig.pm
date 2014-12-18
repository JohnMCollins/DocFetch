# Perl version of dfconfig - assumed read-only

package dfconfig;
use strict;
use XML::LibXML;
use fileexp;

our $Configpath = '~/.local/share/applications/DocFetch';
our $Configroot = "DFConfig";

sub getconfigname ($) {
	my $fname = shift;
	fileexp::fileexp($fname);
}

sub new {
	my $this = {};
	$this->{username} = "";
	$this->{password} = "";
	$this->{cookiefile} = "";
	bless $this;
}

sub load {
	my $this = shift;
	my $node = shift;
	$this->{username} = "";
	$this->{password} = "";
	$this->{cookiefile} = "";
	
	for (my $nd = $node->getFirstChild; $nd; $nd = $nd->getNextSibling)  {
    	my $name = $nd->nodeName;
        if  ($name eq 'username')  {
        	$this->{username} = $nd->textContent;
        }
        elsif ($name eq 'password')  {
        	$this->{password} = $nd->textContent;
        }
        elsif ($name eq 'cookiefile')  {
        	$this->{cookiefile} = $nd->textContent;
        }
	}
	$this;
}

sub loadfile ($;$$) {
	my $this = shift;
	my $filename = shift;
	my $rootname = shift;
	$filename = $Configpath unless $filename;
	$rootname = $Configroot unless $rootname;
	
	$filename = getconfigname($filename);
	return undef unless open(XMLF, $filename);
	my $xmlstr = "";
	$xmlstr .= $_ while (<XMLF>);
	close XMLF;
	my $parser = XML::LibXML->new();
    $parser->keep_blanks(0);
    my $doc = $parser->parse_string($xmlstr);
    return undef unless $doc;
    my $root = $doc->getDocumentElement();
    return undef unless $root->nodeName eq $rootname;
    for (my $nd = $root->getFirstChild; $nd; $nd = $nd->getNextSibling)  {
    	return $this->load($nd) if $nd->nodeName eq 'cdata';
    }
    undef;
}

1;

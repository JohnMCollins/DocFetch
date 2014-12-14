use strict;
package	GetUrls;
use vars qw(@ISA);
@ISA = qw(HTML::Parser);
require	HTML::Parser;

my $parser = new GetUrls;

sub parsestr {
    my $str = shift;
    my $parser = new GetUrls;
    $parser->parse($str);
    $parser->{URLS};
}

sub start {
   my($self,$tag,$attr,$attrseq,$orig) = @_;
   if  ($tag eq	'a')  {
	if  (defined $attr->{href})  {
	    $self->{cur_url} = $attr->{href};
	    $self->{got_href}++;
	}
   }
}

sub end	{
    my ($self,$tag) = @_;
    $self->{got_href}--	if $tag	eq 'a' && $self->{got_href};
}

sub text {
  my ($self,$text ) = @_;
  if ($self->{got_href}) {
	$self->{URLS}{$self->{cur_url}}	.= $text;
  }
}

1;


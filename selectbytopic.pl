#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use pdf;
use Tk;

our $mw, $dbase, $commwindow = 0;

sub disperror {
    my $msg = shift;
    my $nmw = MainWindow->new;
    $nmw->title("Error");
    $nmw->Label(-text => $msg, -relief => 'raised')->pack;
    $nmw->Button(-text => 'OK', -command => sub { $nmw->destroy; })->pack;
    MainLoop;
}

sub selpaper {
	my @sl = $scrolledlist->curselection();
    if  ($#sl < 0)  {
        disperror("No paper selected");
        return;
    }
    my $ind = $sl[0];
    my $cod = $Codes[$ind];
    return if $cod eq "-";
    my $fn = $mw->getSaveFile(-defaultextension => '.pdf', -initialfile => $cod, -title => 'Give PDF file name');
    return if $fn eq "";
    my $pdf	= pdf::getpdf($dbase, $cod);
    unless ($pdf)  {
    	disperror("Could not read PDF for $cod");
    	return
    }
    unless (open(OUTF, ">$fn"))  {
    	disperror("Could not create output file $fn");
    	return
    }
    my $nbytes = length $pdf;
	my $offs = 0;
	while ($nbytes > 0)  {
		my $nout = 4096;
		$nout =	$nbytes	if $nout > $nbytes;
		my $nput = syswrite OUTF, $pdf,	$nout, $offs;
		$offs += $nput;
		$nbytes	-= $nput;
	}
	close OUTF;
	exit 0;
}

sub dispcomment {
    my @sl = $scrolledlist->curselection();
    return  if  $#sl < 0;
    my $ind = $sl[0];
    if  ($commwindow)  {
        $commwindow->destroy;
        $commwindow = 0;
    }
    my $comm = $Comments[$ind];
    return if length($comm) == 0;
    $commwindow = MainWindow->new;
    $commwindow->title("Comments");
    my $tb = $commwindow->Text(-background => 'white', -foreground => 'blue', -font => 'r16')->pack();
    $tb->insert('end', $comm);
    MainLoop;
}

sub massage {
	my $txt = shift;
	$txt =~ s/\{?\\["'`]([aeiou])\}?/$1/g;
	$txt =~ s/[{}~]//g;
	$txt;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$sfh = $dbase->prepare("SELECT ident,author,title,topic,comments FROM topics INNER JOIN item WHERE topics.paper = item.ident AND pdf IS NOT NULL ORDER BY topic,author,title");
$sfh->execute;

$lasttopic = "xxxx";
while (my $row = $sfh->fetchrow_arrayref)  {
	my ($ident,$author,$title,$topic,$comments) = @$row;
	if ($topic ne $lasttopic)  {
	    $lasttopic = $topic;
	    push @Codes, "-";
	    push @Comments, "";
	    push @Rows, "--- $topic ---";
	}
	push @Codes, $ident;
	push @Comments, $comments;
	push @Rows, massage($author) . ' :: ' . massage($title);
}

$mw = MainWindow->new;
#$mw->Icon('/usr/share/icons/gnome/32x32/apps/arts.png');
$mw->title('Select a paper');
$frame = $mw->Frame(-relief => "groove", -borderwidth => 2)->pack(-fill => "x");
$scrolledlist = $frame->Scrolled('Listbox',
                                 -scrollbars => "ose",
                                 -selectmode => 'single',
                                 -width => 200,
                                 -height => $#Rows < 29? $#Rows + 1: 30)->pack();
$scrolledlist->insert('end', @Rows);
$scrolledlist->bind('<<ListboxSelect>>', \&dispcomment);
$mw->Button(-text => "Select", -command => \&selpaper)->pack(-side => 'left', -anchor => 'n');
$mw->Button(-text => "Quit", -command => sub { exit 0; })->pack(-side => 'left', -anchor => 'n');
MainLoop;
#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use pdf;
use Tk;

our $mw, $dbase;

sub disperror {
    my $msg = shift;
    my $nmw = MainWindow->new;
    $nmw->title("Error");
    $nmw->Label(-text => $msg, -relief => 'raised')->pack;
    $nmw->Button(-text => 'OK', -command => sub { $nmw->destroy; })->pack;
    MainLoop;
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
    my $tb = $commwindow->Text(-background => '#FFFFCC', -foreground => 'magenta', -font => 'r16')->pack();
    $tb->insert('end', $comm);
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

sub massage {
	my $txt = shift;
	$txt =~ s/\{?\\["'`]([aeiou])\}?/$1/g;
	$txt =~ s/[{}~]//g;
	$txt;
}

sub do_search {
    my $strw = shift;
    my $isbackw = shift;
    my $string = lc $strw->get();
    if  (length($string) == 0)  {
        disperror("No search string");
        return;
    }

    my @sl = $scrolledlist->curselection();
    my $start = $#sl < 0? 0: $sl[0];
    my $incr = $isbackw? -1: 1;
    my $curr = $start;
    for (;;)  {
        $curr += $incr;
        if  ($curr < 0)  {
            $curr = $#Rows;
        }
        elsif ($curr > $#Rows)  {
            $curr = 0;
        }
        if  ($curr == $start)  {
            disperror("String $string was not found");
            return;
        }
        if  ((index lc $Rows[$curr], $string) != -1)  {
            $scrolledlist->selectionClear(0, 'end');
            $scrolledlist->selectionSet($curr);
            $scrolledlist->see($curr);
            dispcomment();
            return;
        }    
    }
}

sub findstr {
    my $sw = MainWindow->new;
    $sw->title("Search for string");
    my $str = $sw->Entry(-background => 'white', -foreground => 'blue', -font => 'r16')->pack(-side => 'top', -anchor=>'n', -fill => 'x');
    $sw->Button(-text => "Search forward", -command => sub { do_search($str, 0); })->pack(-side =>'left');
    $sw->Button(-text => "Search backward", -command => sub { do_search($str, 1); })->pack(-side =>'left');
    $sw->Button(-text => "Quit search", -command => sub { $sw->destroy; })->pack(-side =>'left');    
    MainLoop;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$sfh = $dbase->prepare("SELECT ident,author,title,comments FROM item WHERE pdf IS NOT NULL ORDER BY author,title");
$sfh->execute;

while (my $row = $sfh->fetchrow_arrayref)  {
	my ($ident,$author,$title,$comment) = @$row;
	push @Codes, $ident;
    push @Comments, $comment;
	push @Rows, massage($author) . ' :: ' . massage($title);
}

$mw = MainWindow->new;
$mw->title('Select a paper');
$frame = $mw->Frame(-relief => "groove", -borderwidth => 2)->pack(-fill => "x");
$scrolledlist = $frame->Scrolled('Listbox',
                                 -background => 'white', -foreground => 'blue', -font => 'r14',
                                 -scrollbars => "ose",
                                 -selectmode => 'single',
                                 -width => 100,
                                 -height => $#Rows < 29? $#Rows + 1: 30)->pack();
$scrolledlist->insert('end', @Rows);
$scrolledlist->bind('<<ListboxSelect>>', \&dispcomment);
$mw->bind('<Key-F3>', \&findstr);
$mw->Button(-text => "Select", -command => \&selpaper)->pack(-side => 'left', -anchor => 'n');
$mw->Button(-text => "Quit", -command => sub { exit 0; })->pack(-side => 'left', -anchor => 'n');
MainLoop;

#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use pdf;
use Tk;

our $mw, $dbase, $lw, $scolledlist, @Rows, @Codes, @Comments, $lastcomment;

sub disperror {
    my $msg = shift;
    my $nmw = MainWindow->new;
    $nmw->title("Error");
    $nmw->Label(-text => $msg, -relief => 'raised')->pack;
    $nmw->Button(-text => 'OK', -command => sub { $nmw->destroy; })->pack;
    MainLoop;
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

sub selt {
    my @sl = $scrolledlist->curselection();
    if  ($#sl < 0)  {
        disperror("No topic selected");
        return;
    }
    my $ind = $sl[0];
    my $cod = $Rows[$ind];
    $topicw->delete(0, 'end');
    $topicw->insert(0, $cod);
    $lw->destroy;
}

sub seltopic {
    my $sfh = $dbase->prepare("SELECT topic FROM topics GROUP BY topic ASC");
    $sfh->execute;
    @Rows = ();
    while (my $row = $sfh->fetchrow_arrayref)  {
	   my ($topic) = @$row;
	   push @Rows, $topic;
    }
    
    $lw = MainWindow->new;
    $lw->title('Select an existing topic');
    my $frame = $lw->Frame(-relief => "groove", -borderwidth => 2)->pack(-fill => "x");
    $scrolledlist = $frame->Scrolled('Listbox',
                                 -scrollbars => "ose",
                                 -selectmode => 'single',
                                 -width => 60,
                                 -height => $#Rows < 29? $#Rows + 1: 30)->pack();
    $scrolledlist->insert('end', @Rows);
    $lw->Button(-text => "Select", -command => \&selt)->pack(-side => 'left', -anchor => 'n');
    $lw->Button(-text => "Quit", -command => sub { $lw->destroy(); })->pack(-side => 'left', -anchor => 'n');
    MainLoop;
}

sub selp {
    my @sl = $scrolledlist->curselection();
    if  ($#sl < 0)  {
        disperror("No paper selected");
        return;
    }
    my $ind = $sl[0];
    my $cod = $Codes[$ind];
    $lastcomment = $Comments[$ind];
    $papw->delete(0, 'end');
    $papw->insert(0, $cod);
    $commw->delete('1.0', 'end');
    $commw->insert('end', $lastcomment);
    $lw->destroy;
}

sub selpaper {
    my $sfh = $dbase->prepare("SELECT ident,author,title,comments FROM item ORDER BY author,title");
    $sfh->execute;
    @Rows = ();
    @Codes = ();
    @Comments = ();
    while (my $row = $sfh->fetchrow_arrayref)  {
	   my ($ident,$author,$title,$comment) = @$row;
	   push @Codes, $ident;
	   push @Rows, massage($author) . ' :: ' . massage($title);
	   push @Comments, $comment;
    }
    
    $lw = MainWindow->new;
    $lw->title('Select a paper');
    my $frame = $lw->Frame(-relief => "groove", -borderwidth => 2)->pack(-fill => "x");
    $scrolledlist = $frame->Scrolled('Listbox',
                                 -background => 'white', -foreground => 'blue', -font => 'r14',
                                 -scrollbars => "ose",
                                 -selectmode => 'single',
                                 -width => 100,
                                 -height => $#Rows < 29? $#Rows + 1: 30)->pack();
    $scrolledlist->insert('end', @Rows);
    $lw->Button(-text => "Select", -command => \&selp)->pack(-side => 'left', -anchor => 'n');
    $lw->Button(-text => "Quit", -command => sub { $lw->destroy(); })->pack(-side => 'left', -anchor => 'n');
    $lw->bind('<Key-F3>', \&findstr);
    MainLoop;
}

sub settopic {
    # Check we've got things in paper field and topic field
    
    my $topic = $topicw->get();
    my $paper = $papw->get();
    my $comments = $commw->get('1.0','end-1c');
    $topic =~ s/^\s*(.*?)\s*$/$1/;
    $paper =~ s/\s+//g;
    if (length($topic) == 0)  {
        disperror("No topic given");
        return;
    }
    if (length($paper) == 0)  {
        disperror("No paper given");
        return;
    }
    if (length($comments) == 0)  {
        disperror("No comments given");
        return;
    }
    my $qpap = $dbase->quote($paper);
    my $qtop = $dbase->quote($topic);
    my $qcomm = $dbase->quote($comments);
    my $sfh = $dbase->prepare("SELECT count(*) FROM item WHERE ident=$qpap");
    $sfh->execute;
    my $row = $sfh->fetchrow_arrayref;
    my ($nrows) = @$row;
    if ($nrows == 0)  {
        disperror("Unknown paper $paper");
        return;
    }
    $sfh = $dbase->prepare("SELECT count(*) FROM topics WHERE paper=$qpap AND topic=$qtop");
    $sfh->execute;
    $row = $sfh->fetchrow_arrayref;
    ($nrows) = @$row;
    if  ($nrows == 0)  {
        $sfh = $dbase->prepare("INSERT INTO topics (paper,topic) VALUES ($qpap,$qtop)");
        $sfh->execute;
    }
    if  ($comments ne $lastcomment)  {
        $sfh = $dbase->prepare("UPDATE item SET comments=$qcomm WHERE ident=$qpap");
        $sfh->execute;
    }
    exit 0;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$mw = MainWindow->new;
$mw->title('Add topic to paper');

$topicw = $mw->Entry()->grid($mw->Button(-text => 'Select topic', -command => \&seltopic),
$papw = $mw->Entry(),
$mw->Button(-text => 'Select paper', -command => \&selpaper));

($commw = $mw->Text(-background => 'white', -foreground => 'blue', -font => 'r14'))->grid(-columnspan => 4);

$mw->Button(-text => "Add Topic", -command => \&settopic)->grid($mw->Button(-text => "Quit", -command => sub { exit 0; }), -columnspan => 2);
MainLoop;

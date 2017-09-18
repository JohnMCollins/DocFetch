#! /usr/bin/env dfperl

use bibref;
use htmlfetch;
use geturls;
use dbaccess;
use pdf;
use Tk;

our $mw, $dbase, $lw, $scolledlist, @Rows, @Codes;

sub disperror {
    my $msg = shift;
    my $nmw = MainWindow->new;
    $nmw->title("Error");
    $nmw->Label(-text => $msg, -relief => 'raised')->pack;
    $nmw->Button(-text => 'OK', -command => sub { $mw->destroy; })->pack;
    MainLoop;
}

sub massage {
	my $txt = shift;
	$txt =~ s/\{?\\["'`]([aeiou])\}?/$1/g;
	$txt =~ s/[{}~]//g;
	$txt;
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
    $papw->delete(0, 'end');
    $papw->insert(0, $cod);
    $lw->destroy;
}

sub selpaper {
    my $sfh = $dbase->prepare("SELECT ident,author,title FROM item ORDER BY author,title");
    $sfh->execute;
    @Rows = ();
    @Codes = ();
    while (my $row = $sfh->fetchrow_arrayref)  {
	   my ($ident,$author,$title) = @$row;
	   push @Codes, $ident;
	   push @Rows, massage($author) . ' :: ' . massage($title);
    }
    
    $lw = MainWindow->new;
    $lw->title('Select a paper');
    my $frame = $lw->Frame(-relief => "groove", -borderwidth => 2)->pack(-fill => "x");
    $scrolledlist = $frame->Scrolled('Listbox',
                                 -scrollbars => "ose",
                                 -selectmode => 'single',
                                 -width => 200,
                                 -height => $#Rows < 29? $#Rows + 1: 30)->pack();
    $scrolledlist->insert('end', @Rows);
    $lw->Button(-text => "Select", -command => \&selp)->pack(-side => 'left', -anchor => 'n');
    $lw->Button(-text => "Quit", -command => sub { $lw->destroy(); })->pack(-side => 'left', -anchor => 'n');
    MainLoop;
}

$dbase = dbaccess::connectdb;
bibref::initDBfields($dbase);

$mw = MainWindow->new;
$mw->title('Add topic to paper');

$topicw = $mw->Entry()->grid($mw->Button(-text => 'Select topic', -command => \&seltopic),
$papw = $mw->Entry(),
$mw->Button(-text => 'Select paper', -command => \&selpaper));

$commw = $mw->Text()->grid(-columnspan => 4);

$mw->Button(-text => "Add Topic")->grid($mw->Button(-text => "Quit", -command => sub { exit 0; }), -columnspan => 2);
MainLoop;
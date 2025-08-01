use Test;

my $debug = 1;
my $ofil = "test0.pdf";

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

use PDF::GraphPaper;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;
use PDF::GraphPaper::Classes;

my $gp = PDF::GraphPaper::Classes::GPaper.new: :margins(0);
isa-ok $gp, PDF::GraphPaper::Classes::GPaper;
is $gp.margins, 0;
is $gp.units, "cm", "units from user's cnf file: {$gp.units}";

my $pdf  = PDF::Lite.new;
isa-ok $pdf, PDF::Lite;

my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

lives-ok {
    create-graph-paper :$page, :$gp; # , :debug;
}, "test sub create-graph-paper";

lives-ok {
    # we must define a SData object to use scales
    my $SD = SData.new;
    create-graph-paper :$page, :$gp, :$SD;
}, "test sub create-graph-paper with scales";

lives-ok {
    my $vscale = True;
    my $SD = SData.new;
    create-graph-paper :$page, :$gp, :$SD, :$vscale, :$debug;
}, "test sub create-graph-paper with vscale";

if $debug {
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil";
}

my $gd = GData.new;
isa-ok $gd, GData, "good default GData object";

my $sd = SData.new;
isa-ok $sd, SData, "good default SData object";

#done-testing;
#=finish

$gp = GPaper.new: :scales(True);
isa-ok $gp, GPaper;
is $gp.margins, 72, "margins 72";
is $gp.scales, True, "has scales";

done-testing;

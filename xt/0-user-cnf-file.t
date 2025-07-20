use Test;

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

my $gp = GPaper.new: :margins(0);
isa-ok $gp, GPaper;
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
    create-graph-paper :$page, :$gp, :scales(True); # , :debug;
}, "test sub create-graph-paper with scales";

lives-ok {
    create-graph-paper :$page, :$gp, :vscale(True); # , :debug;
}, "test sub create-graph-paper with vscale";

my $gd = GData.new;
isa-ok $gd, GData;

my $sd = SData.new;
isa-ok $sd, SData;

done-testing;
=finish

$gp = GPaper.new: :scales(True);
isa-ok $gp, GPaper;
is $gp.margins, 72, "margins 72";
is $gp.scales, True, "has scales";

done-testing;

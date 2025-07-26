use Test;

my $debug = 1;

use PDF::API6;
use PDF::Lite;
use PDF::Content;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

use PDF::GraphPaper;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;
use PDF::GraphPaper::Classes;

my $gp = GPaper.new;
isa-ok $gp, GPaper;

# check the default attr values
$gp.show-spec;

is $gp.margins, 72;

my PDF::Lite $pdf .= new;
isa-ok $pdf, PDF::Lite;

my PDF::Lite::Page $page = $pdf.add-page;
isa-ok $page, PDF::Lite::Page;

lives-ok {
    # create-grid is in PDF/GraphPaper.rakumod
    create-graph-paper :$page, :$gp, :$debug;
}, "test sub create-graph-paper";

if $debug {
   my $ofil = "test2.pdf";
   $pdf.save-as: $ofil;
   say "DEBUG: See output file '$ofil";
}

done-testing;

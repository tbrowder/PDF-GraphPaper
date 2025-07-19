use Test;

my $debug = 1;

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

my $gp = GPaper.new;
isa-ok $gp, GPaper;

# check the default attr values
$gp.show-spec;

is $gp.margins, 72;

my $pdf  = PDF::Lite.new;
isa-ok $pdf, PDF::Lite;

my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

lives-ok {
    # create-grid is in PDF/GraphPaper.rakumod
    #create-grid :$page, :$gp; # , :debug;
    create-graph-paper :$page, :$gp; # , :debug;
}, "test sub create-graph-paper";

if $debug {
   $pdf.save-as: "test2.pdf";
}

done-testing;
=finish

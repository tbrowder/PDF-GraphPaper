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

is $gp.margins, 36;

my $pdf  = PDF::Lite.new;
isa-ok $pdf, PDF::Lite;

my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

lives-ok {
    create-grid :$page, :$gp; # , :debug;
}, "test sub create-grid";

lives-ok {
    create-scale :$page, :$gp; # , :debug;
}, "test sub create-scale";

if $debug {
   $pdf.save-as: "test3.pdf";
}

# test changing margin setting...
$gp.tm: 6;
is $gp.tm, 6, "set tm 6";
is $gp.bm, $gp.margins, "check bm still default {$gp.margins}";

done-testing;
=finish

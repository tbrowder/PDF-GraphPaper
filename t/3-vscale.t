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
    create-graph-paper :$page, :$gp; # , :debug;
}, "test sub create-graph-paper";

lives-ok {
    my $SD = SData.new;
    my $GD = GData.new;
    my ($LLX, $LLY) = 72, 72;
    my $vscale = False;
    create-scales :$page, :$gp, :$GD, :$SD, :$LLX, :$LLY, :$vscale;
}, "test sub create-scales";

if $debug {
   my $ofil = "test3.pdf";
   $pdf.save-as: $ofil; 
   say "DEBUG: See output file '$ofil'";
}

# test changing margin settings...
$gp.tm: 6;
is $gp.tm, 6, "set tm 6";
is $gp.bm, $gp.margins, "check bm still default {$gp.margins}";

done-testing;
=finish

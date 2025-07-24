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

is $gp.margins, 72;

my $pdf  = PDF::Lite.new;
isa-ok $pdf, PDF::Lite;

my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my $SD = SData.new;
isa-ok $SD, SData;
is $SD.angle, 90, "default angle 90 degrees";
is $SD.Ls, True, "default left scale";
is $SD.Bs, True, "default bottom scale";

lives-ok {
    my $Ls = True; # use a left-side scale
    my $SD = SData.new: :$Ls;
    my $GD = GData.new;
    my ($LLX, $LLY) = 72, 72;
    my $vscale = False;
    create-scales :$page, :$gp, :$GD, :$SD, :$LLX, :$LLY, :$vscale;
}, "test sub create-scales";

if $debug {
   my $ofil = "test5.pdf";
   $pdf.save-as: $ofil; 
   say "DEBUG: See output file '$ofil'";
}

$gp.tm: 6;
is $gp.tm, 6, "set tm 6";
is $gp.bm, $gp.margins, "check bm still default {$gp.margins}";

done-testing;

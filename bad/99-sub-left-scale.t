use Test;

my $debug = 1;
my $ofil = "test99.pdf";

# use required libs
use MacOS::NativeLib "*";
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::FontObj;

use PDF::GraphPaper;
use PDF::GraphPaper::FreeFonts;
use PDF::GraphPaper::Subs;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my %fonts = get-loaded-fonts-hash;
my $font = %fonts<t>;
isa-ok $font, PDF::Content::FontObj;

my $font-size = 12;

my ($x, $y) = 300, 300;
my $angle   = 0;
my $length  = 144;
my $width   = 0.75;
my $align   = "right";
my $valign  = "center";
my $number  = 10;

lives-ok {
    draw-line :$x, :$y, :$length, :$width, :$angle, :$page;
}, "draw-line";

lives-ok {
    print-scale-number $number, :$x, :$y, :$align, :$valign, :$font, :$font-size, :$page;
}, "print-scale-number";

if $debug {
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;

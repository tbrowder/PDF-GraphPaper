use Test;

my $debug = 1;

# use required libs
use MacOS::NativeLib "*";
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;

use LScale;

my PDF::Lite $pdf .= new;
my PDF::Lite::Page $page = $pdf.add-page;
isa-ok $page, PDF::Lite::Page;

my ($x, $y) = 300, 300;
my $angle   = 45;
my $length  = 144;
my $width   = 0.75;

lives-ok {
    draw-line :$x, :$y, :$length, :$width, :$angle, :$page;
}, "draw-line";

if $debug {
    my $ofil = "test7.pdf";
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;


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
use LScale::FreeFonts;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my $llx = 36;
my $lly =  0;
lives-ok {
    create-left-scale :$page, :$llx, :$lly;
}, "create-left-scale";

if $debug {
    my $ofil = "test8.pdf";
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;

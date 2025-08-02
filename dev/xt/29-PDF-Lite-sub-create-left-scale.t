use Test;

my $debug = 1;
my $ofil = "test29.pdf";

# use required libs
use MacOS::NativeLib "*";

#use PDF::API6;
use PDF::Lite;

#use PDF::Content::Color :ColorName, :color;
#use PDF::Content::XObject;
#use PDF::Tags;
#use PDF::Content::Text::Box;

use LScale-PDF-Lite;

=begin comment
# API6
my PDF::API6 $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;
=end comment

#=begin comment
# PDF-Lite
my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Lite::Page;
#=end comment

my $font = $pdf.core-font(:family<Times-Roman>);
my $font-size = 12;

my $llx = 36;
my $lly =  0;
lives-ok {
    create-left-scale :$page, :$llx, :$lly, :$font, :$font-size;
}, "create-left-scale";

if $debug {
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;

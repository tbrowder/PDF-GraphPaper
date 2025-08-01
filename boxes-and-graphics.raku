#!/bin/env raku

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

my $p = $*PROGRAM.basename;
$p ~~ s/:i '.' pdf $//;
$p ~= ".pdf";
my $ofile = $p;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Demonstrates drawing cells containing text and graphics.
    HERE
    exit
}

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
# letter, portrait
$page.media-box = [0, 0, 8.5*72, 11*72];

my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 8*72;

for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-cell :$text, :$page, :x0($x), :$y0, :$width, :$height;
    write-cell-line :$text, :$page, :x0($x), :$y0, :$width, :$height,
    :Halign<left>;
}

$pdf.save-as: $ofile;
say "See output file: ", $ofile;

#==== subroutines line
# all subs moved to Checkwriter/Utils.rakumod

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

use PDF::GraphPaper::Subs;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my ($x, $y) = 300, 300;
my $angle   = 45;
my $length  = 144;
my $width   = 0.75;

lives-ok {
    draw-line :$x, :$y, :$length, :$width, :$angle, :$page;
}, "draw-line";

if $debug {
    my $ofil = "test9.pdf";
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;

=finish

sub print-text(
    $text,
    :$page!,
    # text origin
    :$x = 72, :$y = 300,
    :$font!,   # the font object
    :$angle = 0;
    :$font-size = 16,
    :$align = "left", # right, justify
    # valign options: top, bottom, center (or ?)
    # syntax from David
    :$valign! is copy, # per David (but without the '!')
    :$baseline = $valign // 'alphabetic', # per David (but what does 'alphabetic' mean?)
    ) {

    #==========================================
    $page.graphics: {
        # my $gb = "GBUMC";
        # my $tx = $cx;
        # my $ty = $cy + ($height * 0.5) - $line1Y;
        # where $x/$y is the desired reference point
        .transform: :translate($x, $y);
        if $angle {
            .transform: :rotate($angle);
        }
        #.FillColor = color White; #rgb(0, 0, 0); # color Black
        .font = $font, # %fonts<hb>, #.core-font('HelveticaBold'),
                 $font-size; # the size
        .print: $text, :$align; #, :$valign;
    }
}

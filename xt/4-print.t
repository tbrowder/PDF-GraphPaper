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

use PDF::GraphPaper::FreeFonts;
my %fonts = get-loaded-fonts-hash;
my $font = %fonts<t>;

sub print-text {...};

my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my ($x, $y) = 72, 300;

my $text = "Test text";
print-text $text, :$font, :$page;

if $debug {
    my $ofil = "test4.pdf";
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

done-testing;

sub print-text(
    $text,
    :$page!,
    # text origin
    :$x = 72, :$y = 300,
    :$font-size = 16,
    :$font!,   # the font object
    :$angle = 0;
    :$align = "left", # right, justify
#   :$valign = "baseline", # default is baseline which is zero reference
              # options: top, bottom, center
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

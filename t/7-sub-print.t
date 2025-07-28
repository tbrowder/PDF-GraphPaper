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

use PDF::GraphPaper;
use PDF::GraphPaper::FreeFonts;
use PDF::GraphPaper::Classes;

my %fonts = get-loaded-fonts-hash;
my $font = %fonts<t>;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Content::Page;

my ($x, $y) = 100, 400;
my $angle = 45;

my $gp = GPaper.new;
my $text = "Test text at angle $angle";
text-line  $text, :$x, :$y, :$gp, :$font, :$angle, :$page;

if $debug {
    my $ofil = "test7.pdf";
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
    # per David (but what does 'alphabetic' mean?)
    :$baseline = $valign // 'alphabetic', 
    ) {

    #==========================================
    $page.graphics: {
        .Save;
        # my $gb = "GBUMC";
        # my $tx = $cx;
        # my $ty = $cy + ($height * 0.5) - $line1Y;
        # where $x/$y is the desired reference point
        .transform: :translate($x, $y);
        if $angle {
            .transform: :rotate($angle);
        }
        #.FillColor = color White; #rgb(0, 0, 0); # color Black
        .font = $font,      # %fonts<hb>, #.core-font('HelveticaBold'),
                $font-size; # the size
        .print: $text;      #, :$align; #, :$valign;
        .Restore;
    }
}

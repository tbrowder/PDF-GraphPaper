unit module LScale;

use MacOS::NativeLib "*";
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

use LScale::FreeFonts;

my %fonts = get-loaded-fonts-hash;

my $font = %fonts<t>;
my $font-size = 12;

sub create-left-scale(
    :$page!,
    :$llx = 36,
    :$lly =  0,
) is export {
    # at llx, lly
    # create a vertical line
    # along the line create tick marks align right, valign  enter
    # intervals are every two tenths of a unit
    # major tick marks are 0.75 points in thickness, ? units in length
    # minor tick marks are ? points in thickness, ? units in length
    # normal tick marks are ? points in thickness, ? units in lengt

    # standard linewidths in PS points
    # mid-grid line only for even number of cells-per-grid
    # has $.cell-linewidth     is rw = 0;    # very fine line
    # has $.mid-grid-linewidth is rw = 0.75; # heavier line width (for even cpg)
    # has $.grid-linewidth is rw     = 1.40; # heavier line width

    my $units = 72; # inches

    # tick thicknesses (linewidths)
    my $tic-thick0  = 0;
    my $tic-thick5  = 0.75;
    my $tic-thick10 = 1.40;
    # tick lengths
    my $tic-length0  = 2;
    my $tic-length5  = 4;
    my $tic-length10 = 6;

    my $height = 11*72; #$gp.page-height;
    say qq:to/HERE/;
    DEBUG: llx = $llx
           lly = $lly
           height = $height
    HERE

    $page.graphics: {

    .transform: :translate($llx, $lly);
    # VERTICAL line
    .LineWidth = 0.7; # ?$gp.cell-linewidth;
    .MoveTo: 0, 0;
    .LineTo: 0, $height; ## page height$ury, $GD.graph-height;
    .Stroke;

    # tick marks and numbers
    my $y = 0;
    my $inc = 0.1 * $units;
    my $tick-angle = 0; # degrees
    my $tnum = 0;
    my ($linewidth, $length);
    my $scale-number = 0; # for the scale number markings
    my $put-scale-number = True; # first pass
    while $y <= $height {
        ++$tnum; # 1..10
        # make a tick mark every increment
        # parameters depend on increment number
        #   marks are from vertical centerline to desire mark length
        # make a longer tick mark every 5th increment
        # make an even longer tick mark every 10th increment
        # print a scale number at zero and every 10th increment
        if $tnum == 5 {
            $linewidth = $tic-thick5;
            $length    = $tic-length5;
        }
        elsif $tnum == 10 {
            $linewidth = $tic-thick10;
            $length    = $tic-length10;
            ++$scale-number;
            $put-scale-number = True;
        }
        else {
            $linewidth = $tic-thick0;
            $length    = $tic-length0;
        }

        draw-line :$page, :angle($tick-angle), :x($llx), :$y,
                          :$linewidth, :$length;

        =begin comment
        if $put-scale-number {
            my $delta-x = 2 + $tic-length10;
            # in this module...
            unless $scale-number.defined {
                die "FATAL: Undefined";
            }
            print-scale-number :text("$scale-number"), :$page, :x($delta-x), 
                               :$y, :$font, :$font-size,
                               ; # add angle and color
            $put-scale-number = False;
        }
        =end comment

        # increment by 0.1 of the scale units
        $y += $inc;
        # reset increment counter if need be
        if $tnum == 10 {
            $tnum = 0;
        }
    }
    } # end of $page.graphics
}

# print-scale-number :$page, :x($delta-x), :$y, :$font,
#                    :$font-size; # add angle and color
# print-scale-number :$x, :$y, :$length, :$width, :$angle, :$page;
sub print-scale-number(
Str :$text!,
    :$page!,
    :$x!,
    :$y!,
    :$font!,
    :$font-size!, # add angle and color
    :$align!,
    :$valign is copy,
    :$baseline = $valign // "alphabetic",
    :$angle = 0,
    :$debug,
) is export {

    $page.text: {
        # translate to x, y
        .text-transform: :translate($x, $y); 
        .font = $font, $font-size;
        if $valign {
       	    .print: :$text, :$align, :$valign, :$baseline;
        }
        else {
       	    .print: :$text, :$align, :$baseline;
        }
    }

} # end of sub print-scale-number

# draw-line :$page, :angle(), :x(), y(), :length(), :width();
# draw-line :$x, :$y, :$length, :$linewidth, :$angle, :$page;
sub draw-line(
    :$page!,
    :$angle!,
    :$x!,
    :$y!,
    :$length!,
    :$linewidth!;
    :$debug,
) is export {
    # The line's x=0 and y=0 are at the desired rotation point
    #   at the left edge of the line (after rotation).
    #   and the width is in the y direction, length in the x direction
    # The line's angle reference is horizontal at zero, positive increasing
    #   counter-clockwise
    $page.graphics: {
        #.Save;
        .transform: :translate($x, $y);
        if $angle {
            .transform: :rotate($angle);
        }

        # starting at x=0, y=0
        .LineWidth = $linewidth;
        .MoveTo: 0,       0;
        .LineTo: $length, 0;
        .Stroke;
        #.Restore;
    }
} # draw-line

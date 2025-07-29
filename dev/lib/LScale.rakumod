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

    # tick thicknesses (widths)
    my $tic-thick0  = 0;
    my $tic-thick5  = 0.75;
    my $tic-thick10 = 1.40;
    # tick lengths
    my $tic-length0  = 0;
    my $tic-length5  = 0.75;
    my $tic-length10 = 1.40;

    my $height = 11*72; #$gp.page-height;
    say qq:to/HERE/;
    DEBUG: llx = $llx
           lly = $lly
           height = $height
    HERE

    my $g = $page.gfx;
    $g.Save;

    $g.translate;
    # VERTICAL line
    $g.LineWidth = 0.7; # ?$gp.cell-linewidth;
    $g.MoveTo: 0, 0;
    $g.LineTo: 0, $height; ## page height$ury, $GD.graph-height;
    $g.Stroke;


        # tick marks and numbers
        $g.MoveTo: 0, 0;
        my $y = 0;
        my $inc = 0.1 * $units;
        my $tick-angle = 0; # degrees
        my $tnum = 0;
        my ($width, $length);
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
                $width  = $tic-thick5;
                $length = $tic-length5;
            }
            elsif $tnum == 10 {
                $width  = $tic-thick10;
                $length = $tic-length10;
                ++$scale-number;
                $put-scale-number = True;
            }
            else {
                $width  = $tic-thick0;
                $length = $tic-length0;
            }


            # in Subs
            draw-line :$page, :angle($tick-angle), :x($llx), :$y,
                              :$width, :$length;

            if $put-scale-number {
                my $delta-x = 2 + $tic-length10;
                # in this module...
                print-scale-number $scale-number, :$page, :x($delta-x), :$y, :$font,
                                           :$font-size; # add angle and color
                $put-scale-number = False;
            }

            # increment by 0.1 of the scale units
            $y += $inc;
            # reset increment counter if need be
            if $tnum == 10 {
                $tnum = 0;
            }
        }
    $g.Restore;
}

sub draw-line(
) is export {
}

sub print-scale-number(
) is export {
}

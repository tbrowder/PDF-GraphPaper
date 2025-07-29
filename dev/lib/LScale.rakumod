use PDF::Lite;

use LScale::FreeFonts;

unit module LScale;

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
    # normal tick marks are ? points in thickness, ? units in length
    my $g = $page.gfx;
    $g.Save;

    $g.translate;

    $g.Restore;
}

sub print-number(
) is export {
}


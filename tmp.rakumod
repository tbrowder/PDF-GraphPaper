unit module PDF::GraphPaper;

use MacOS::NativeLib "*";
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

class GPaper {
    has $.units is rw = "in";       # default
    has $.media is rw = "letter";   # default
    has $.orientation = "portrait"; # default
    #=========================
    #== defaults for Letter paper
    has $.margins is rw       = 0.5 * 72;
    # allow for custom margins for each edge
    has $.margin-t is rw = -1; # -1 indicates not set
    has $.margin-b is rw = -1; # -1 indicates not set
    has $.margin-l is rw = -1; # -1 indicates not set
    has $.margin-r is rw = -1; # -1 indicates not set

    has $.cell-size-x is rw   = 0.1 * 72; # * 72; desired minimum cell size (inches)
    has $.cell-size-y is rw   = 0.1 * 72; # * 72; desired minimum cell size (inches)
    has $.page-width is rw    = 8.5 * 72;
    has $.page-height is rw   = 11  * 72;

    has $.major-grids is rw    = True;
    has $.minor-grids is rw    = True; # forced False if cells-per-grid is odd
    has $.cells-per-grid is rw = 10;   # heavier line every X cells

    # standard linewidths in PS points
    # TODO allow customization
    # mid-grid line only for even number of cells-per-grid
    has $.cell-linewidth is rw     =  0;    # very fine line
    has $.mid-grid-linewidth is rw =  0.75; # heavier line width (for even cpg)
    has $.grid-linewidth is rw     =  1.40; # heavier line width

    submethod TWEAK {

    }
}

sub show-paper-sizes(
    :$debug,
    --> List
) is export {
    say "Known paper sizes (PS points):";
    my %h;
    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
        %h{$k} = [$v];
    }
    for %h.keys.sort -> $k {
        my $v = %h{$k};
        say "  $k: $v";
    }
}

sub get-paper-dimens(
    $code is copy where ( $code ~~ /:i letter | tabloid | ledger | legal | statement
                              | executive | folio | quarto
                              | a0 | a1 | a2 | a3 | a4 | a5
                              | b4 | b5 / ),
    :$debug,
    --> List # llx, lly, urx, ury (PS points)
) is export {
    my %h;
    $code .= tc;

    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
        %h{$k} = [$v];
    }
    for %h.keys.sort -> $k {
        my $v = %h{$k};
        say "  $k: $v" if $debug;
    }

    my $size;
    if %h{$code}:exists {
        $size = %h{$code};
        say "Paper code '$code' size (PS points):" if $debug;
        say "  $size" if $debug;
    }
    else {
        $size = "Unrecognized paper code '$code'";
        say "unrecognized paper code '$code'" if $debug;
    }

    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
    }

    $size;
} # get-paper-dimens

sub deg2rad($degrees) {
    $degrees * pi / 180
}

sub rad2deg($radians) {
    $radians * 180 / pi
}

sub create-grid(
    :$page!,
    PDF::GraphPaper::GPaper :$p!, # 
    :$code = "Letter",
    :$debug,
    ) is export {

    #===============================================================
    # Determine maximum horizontal and vertical grid squares 
    # (or cells if no grids are desired) for the desired paper,
    # orientation, cell-size, and  margins.
    #===============================================================
    # defaults (with limited user inputs via the $p object for now):
    my $page-width  = 8.5 * 72; # <= should be done in TWEAK
    my $page-height = 11  * 72; # <= should be done in TWEAK
    # individual margin settings should be done in TWEAK

    my $max-graph-width  = $page-width  - $p.margins * 2;
    my $max-graph-height = $page-height - $p.margins * 2;
    say "DEBUG: max-graph-width = $max-graph-width" if $debug;
    say "DEBUG: \$p.cell-size-x: {$p.cell-size-x}";
    say "DEBUG: \$p.cell-size-y: {$p.cell-size-y}";

    my $max-ncells-x = floor($max-graph-width  / $p.cell-size-x);
    my $max-ncells-y = floor($max-graph-height / $p.cell-size-y);

#   $p.major-grids = True;
    my $ngrids-x = $p.major-grids 
                   ?? floor($p.$max-ncells-x div $p.cells-per-grid) 
                   !! 0;
    my $ngrids-y = $p.major-grids 
                   ?? floor($p.$max-ncells-y div $p.cells-per-grid) 
                   !! 0;

    my $ncells-x = $ngrids-x 
                   ?? ($ngrids-x * $p.cells-per-grid) 
                   !! $max-ncells-x;

    my $ncells-y = $ngrids-y 
                   ?? ($ngrids-y * $p.cells-per-grid) 
                   !! $max-ncells-y;

    my $graph-size-width = $p.major-grids
                     ?? ($ngrids-x * $p.cells-per-grid * $p.cell-size-x)
                     !! ($ncells-x * $p.cell-size-x);

    my $graph-size-height = $p.major-grids
                     ?? ($ngrids-y * $p.cells-per-grid * $p.cell-size-y)
                     !! ($ncells-y * $p.cell-size-y);

    if $debug {
        my $csx = $p.cell-size-x/72.0;
        my $csy = $p.cell-size-y/72.0;
        my $m  = $p.margins/72.0;
        my $cpgx = $p.cells-per-grid-x;
        my $cpgy = $p.cells-per-grid-y;
        say qq:to/HERE/;
        Current graph paper metrics:
          cell size (in)     : $csx  x $csy
          margins (in)       :   $m
          cells per grid in x:  $cpgx
          cells per grid in y:  $cpgy
          cells in x         :
            grids in x       :
          cells in y         :
            grids in y       :

        HERE
    }

=begin comment
    # caller should do this:
    my $pdf  = PDF::Lite.new;
    $pdf.media-box = 0, 0, $page-width, $page-height;
    my $page = $pdf.add-page;
=end comment

    # Translate to the lower-left corner of the grid area
    my $llx = 0 + 0.5 * $page-width - 0.5 * $graph-size-width;
    my $lly = $page-height - 72 - $graph-size-height;
    $page.graphics: {
        .transform: :translate($llx, $lly);

        # draw horizontal lines, $y is varying 0 to $twidth
        #   bottom to top
        for 0..$ncells-y -> $i {
            my $y = $i * $p.cell-size-y;
            if not $p.major-grids {
                .LineWidth = $p.cell-linewidth;
            }
            elsif not $i mod 10 {
                .LineWidth = $p.grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $p.mid-grid-linewidth;
            }
            else {
                .LineWidth = $p.cell-linewidth;
            }
            # HORIZONTAL line
            .MoveTo: 0,                 $y;
            .LineTo: $graph-size-width, $y;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$p.cell-linewidth}" if $debug;

        # draw vertical lines, $x is varying 0 to $twidth
        #   left to right
        for 0..$ncells-x -> $i {
            my $x = $i * $p.cell-size-x;
            if not $p.major-grids {
                .LineWidth = $p.cell-linewidth;
            }
            elsif not $i mod 10 {
                .LineWidth = $p.grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $p.mid-grid-linewidth;
            }
            else {
                .LineWidth = $p.cell-linewidth;
            }
            # VERTICAL line
            .MoveTo: $x, 0;
            .LineTo: $x, $graph-size-height;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$p.cell-linewidth}" if $debug;
    }

=begin comment
    # caller should do this:
    $pdf.save-as: $ofil;
    say "See output file: '$ofil'";
=end comment
} # sub create-grid

sub run(@args) is export {
    say "Executing {$*PROGRAM.basename}";
}

sub help is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [options...]
    HERE
}


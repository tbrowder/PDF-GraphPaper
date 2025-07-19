unit module PDF::GraphPaper;

use MacOS::NativeLib "*";
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

use PDF::GraphPaper::Vars;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Classes;

sub show-spec(
    :$debug,
    ) is export {
    my $gp = GPaper.new;
    $gp.show-spec :$debug;
}

sub check-inputs(:$page!, :$gp!) is export {
    unless $page ~~ PDF::Content::Page {
        die "FATAL: \$page is NOT a PDF::Content::Page";
    }
    unless $gp ~~ PDF::GraphPaper::Classes::GPaper {
        die "FATAL: \$gp is NOT a PDF::GraphPaper::Classes::GPaper";
    }

}

sub text-line(
    # caller provides the $page to mark on
    :$page!,
    :$gp!, # the GPaper object
    :$code = "Letter", # paper type
    :$debug,
    ) is export {
    check-inputs :$page, :$gp;
}

sub create-grid(
      :$page!,
      :$gp!,
    ) is export {
    check-inputs :$page, :$gp;

    # for horizontal scales
        # for top numbers and tick marks
        # for bottom numbers and tick marks
    # for vertical scales
        # for left side numbers and tick marks
        # for right side numbers and tick marks
}

sub vscale(
    # caller provides the $page to mark on
    :$page!,
    :$gp!, # the GPaper obj
    :$code = "Letter", # paper type
    :$debug,
    ) is export {
    check-inputs :$page, :$gp;
}

sub create-scales(
      :$page!,
      :$gp!,
    ) is export {
    check-inputs :$page, :$gp;

    # for horizontal scales
        # for top numbers and tick marks
        # for bottom numbers and tick marks
    # for vertical scales
        # for left side numbers and tick marks
        # for right side numbers and tick marks
}

# formerly sub create-grid(
sub create-graph-paper(
    # caller provides the $page to mark on
    :$page!,
    :$gp!, # the GPaper object
    :$code = "Letter", # paper type
    :$debug,
    ) is export {

    check-inputs :$page, :$gp;

    #===============================================================
    # Determine maximum horizontal and vertical grid squares
    # (or cells if no grids are desired) for the desired paper,
    # orientation, cell-size, and  margins.
    #===============================================================
    # defaults (with limited user inputs via the $gp object for now):
    my $page-width  = $gp.page-width; #  8.5 * 72;
    my $page-height = $gp.page-height; #11.0 * 72;

    # the 4 default margins from $gp
    =begin comment
    # allow for custom margins for each edge
    has $.margin-t is rw = -1; # -1 indicates not set
    has $.margin-b is rw = -1; # -1 indicates not set
    has $.margin-l is rw = -1; # -1 indicates not set
    has $.margin-r is rw = -1; # -1 indicates not set
    =end comment

    my ($Tm, $Bm, $Lm, $Rm);
    $Tm = $gp.margin-t > -1 ?? $gp.margin-t !! $gp.margins;
    $Bm = $gp.margin-b > -1 ?? $gp.margin-b !! $gp.margins;
    $Lm = $gp.margin-l > -1 ?? $gp.margin-l !! $gp.margins;
    $Rm = $gp.margin-r > -1 ?? $gp.margin-r !! $gp.margins;

    my $max-graph-width  = $page-width  - ($Lm + $Rm);
    my $max-graph-height = $page-height - ($Tm + $Bm);

    say "DEBUG: max-graph-width  = $max-graph-width" if 1 or $debug;
    say "DEBUG: max-graph-height = $max-graph-height" if 1 or $debug;

    say "DEBUG: \$gp.cell-size-x: {$gp.cell-size-x}" if $debug;
    say "DEBUG: \$gp.cell-size-y: {$gp.cell-size-y}" if $debug;

    my $max-ncells-x = floor($max-graph-width  / $gp.cell-size-x);
    my $max-ncells-y = floor($max-graph-height / $gp.cell-size-y);

    say "DEBUG: \$max-ncells-x: {$max-ncells-x}" if $debug;

    #===================================================
    # calculate grid data from current page values above
    #===================================================

    # major grids
    my $ngrids-x = $gp.major-grids
                   ?? floor($max-ncells-x div $gp.cells-per-grid)
                   !! 0;
    my $ngrids-y = $gp.major-grids
                   ?? floor($max-ncells-y div $gp.cells-per-grid)
                   !! 0;

    # minor grids
    my $ncells-x = $ngrids-x
                   ?? ($ngrids-x * $gp.cells-per-grid)
                   !! $max-ncells-x;
    my $ncells-y = $ngrids-y
                   ?? ($ngrids-y * $gp.cells-per-grid)
                   !! $max-ncells-y;

    # calculate actual gridded area dimensions
    my $graph-width = $gp.major-grids
               ?? ($ngrids-x * $gp.cells-per-grid * $gp.cell-size-x)
               !! ($ncells-x * $gp.cell-size-x);
    my $graph-height = $gp.major-grids
               ?? ($ngrids-y * $gp.cells-per-grid * $gp.cell-size-y)
               !! ($ncells-y * $gp.cell-size-y);

    if 0 or $debug {
        my $csx  = $gp.cell-size-x/72.0;
        my $csy  = $gp.cell-size-y/72.0;
        my $m    = $gp.margins/72.0;
        my $ngx  = $ngrids-x;
        my $ngy  = $ngrids-y;
        my $ncx  = $ncells-x;
        my $ncy  = $ncells-y;
        my $cpgx =
        say qq:to/HERE/;
        Current graph paper metrics:
          cell size (in)     : $csx  x $csy
          margins (in)       :   $m
          cells in x         :   $ncx
            grids in x       :     $ngx
          cells in y         :   $ncy
            grids in y       :     $ngy

        HERE
    }

    # Translate to the lower-left corner of the grid area
    my $mid-point-x = 0.5 * $graph-width;
    my $mid-point-y = 0.5 * $graph-height;

    my $llx = 0 + (0.5 * $page-width)  - (0.5 * $graph-width);
    my $lly = 0 + (0.5 * $page-height) - (0.5 * $graph-height);

    # define more page parameters to ease creating independent
    # subroutines

    my $major-grids        = $gp.major-grids;
    my $cell-size-y        = $gp.cell-size-y;
    my $cell-size-x        = $gp.cell-size-x;
    my $cell-linewidth     = $gp.cell-linewidth;
    my $mid-grid-linewidth = $gp.mid-grid-linewidth;
    my $grid-linewidth     = $gp.grid-linewidth;

    =begin comment
    #==== draw any scales
    if $vscale {
        draw-vscale $page, :$llx, :$debug;

        # finished with this page
        return;
    }
    elsif $handle-point {

        # finished with this page
        return;
    }
    =end comment

    =begin comment
    #========================
    # draw any scales desired
    #========================
    # create-scales
    create-scales :$page;

    #==============
    # draw the grid
    #==============
    # create-grid
    create-grid :$page;
    =end comment

    =begin comment
    $page.graphics: {
        .transform: :translate($llx, $lly);

        # draw horizontal lines, $y is varying 0 to $twidth
        #   bottom to top
        for 0..$ncells-y -> $i {
            my $y = $i * $gp.cell-size-y;
            if not $gp.major-grids {
                .LineWidth = $gp.cell-linewidth;
            }
            elsif not $i mod 10 {
                .LineWidth = $gp.grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $gp.mid-grid-linewidth;
            }
            else {
                .LineWidth = $gp.cell-linewidth;
            }
            # HORIZONTAL line
            .MoveTo: 0,            $y;
            .LineTo: $graph-width, $y;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$gp.cell-linewidth}" if $debug;

        # draw vertical lines, $x is varying 0 to $twidth
        #   left to right
        for 0..$ncells-x -> $i {
            my $x = $i * $gp.cell-size-x;
            if not $gp.major-grids {
                .LineWidth = $gp.cell-linewidth;
            }
            elsif not $i mod 10 {
                .LineWidth = $gp.grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $gp.mid-grid-linewidth;
            }
            else {
                .LineWidth = $gp.cell-linewidth;
            }
            # VERTICAL line
            .MoveTo: $x, 0;
            .LineTo: $x, $graph-height;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$gp.cell-linewidth}" if $debug;
    }
    =end comment

#} # sub create-grid
} # sub create-graph-paper

sub run(@args) is export {
    say "Executing {$*PROGRAM.basename}...";
    =begin comment
    # input vars for run
    # from help:
    <file.pdf>  # output pdf file
    show-spec   # show spec file format
    # options
    force
    spec=X  X is user spec file
    vscale # put vert scale, default 0.5, 0 origin, inches
           # t
    =end comment

    my $debug     = 0;
    my $force     = 0;
    my $ofil;
    my $spec; # use a spec file

    # the action subs
    my $show-spec = 0;
    # action subs requiring PDF output
    my $pdf-vscale    = 0;
    my $pdf-text-line = 0;
    my $pdf-grid      = 0;

    my $pdf = 0;

    for @args {
        when /:i '.pdf' $/ {
            $ofil = $_.IO;
            ++$pdf;
        }
        when /:i te $/ {
            ++$pdf-text-line;
            ++$pdf;
        }
        when /:i v / {
            ++$pdf-vscale;
            ++$pdf;
        }
        when /^:i sh / {
            # create the default spec file, show on STDOUT
            ++$show-spec;
        }
        when /^:i spec '=' (\S+)  / {
            # read the input spec file
            $spec = ~$0;
            unless $spec.IO.r {
                say "FATAL: Unable to read config file '$spec'";
                say "Exiting...";
                exit;
            }
        }
        when /^:i d / {
            ++$debug;
        }
        when /^:i f / {
            ++$force;
        }
        default {
            say "FATAL: Unknown arg '$_'";
            say "Exiting...";
            exit;
        }
    }

    # handle the args
    if $show-spec {
        show-spec :$debug;
    }
    elsif $pdf {
        # these require a PDF output file
        if $pdf-vscale {
            say "Creating a vscale...";
        }
        elsif $pdf-text-line {
            say "Creating a text-line...";
        }
        else {
            # creates a pdf file and calls sub create-grid with it
            say "Creating a graph...";
        }
        say "Creating output file '$ofil'...";
    }
    elsif $force {
        say "Added the 'force' option for overwriting files";
    }
    else {
        say "FATAL: Unexpected arg '$_'";
        exit;
    }

    if $pdf {
        # open the output file
        my $pdf = PDF::Lite.new;
        my $page = $pdf.add-page;
        my $gp = PDF::GraphPaper::Classes::GPaper.new;
        # make any changes to $gp
        #create-grid :$page, :$gp, :vscale, :$debug;
        create-graph-paper :$page, :$gp, :$debug;
        if $ofil.IO.r {
            unless $force {
                say "Output file '$ofil' exists...exiting";
                exit;
            }
            say "Overwriting existing file '$ofil'...";
            $pdf.save-as: $ofil;
        }
        else {
            $pdf.save-as: $ofil;
        }
        say "See output file: '$ofil'";
    }
}

sub help is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [options...]

    Creates a gridded graph on single page using
    default settings.

    The user can define his or her own defaults in
    a specification file placed at '\$HOME/pdf-graphpaper.cnf'.

    Modes:
      <file.pdf> - The output file for the graph (must end in '.pdf')
      show-spec  - Shows a default specification file on STDOUT

    Options:
      force      - Allows overwriting an existing file
      spec=X     - Where X is a specification file name
      vscale     - Creates a vertical scale at the left
                     of a page with X=0.5in and Y=0in
    HERE
}

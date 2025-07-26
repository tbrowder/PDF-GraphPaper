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
use PDF::GraphPaper::FreeFonts;

# try using a BEGIN block if need be
our %fonts = get-loaded-fonts-hash;

sub show-spec(
    :$debug,
    ) is export {
    my $gp = GPaper.new;
    $gp.show-spec :$debug;
}

sub check-inputs(:$page!, :$gp!, :$GD, :$SD, :$vscale, :$debug) is export {
    unless $page ~~ PDF::Content::Page {
        die "FATAL: \$page is NOT a PDF::Content::Page";
    }
    unless $gp ~~ PDF::GraphPaper::Classes::GPaper {
        die "FATAL: \$gp is NOT a PDF::GraphPaper::Classes::GPaper";
    }
    my $err = 0;
    if $GD.defined and $GD !~~ PDF::GraphPaper::Classes::GData {
        ++$err;
        note "FATAL: \$GD is NOT a PDF::GraphPaper::Classes::GData";
    }
    if $SD.defined and $SD !~~ PDF::GraphPaper::Classes::SData {
        ++$err;
        note "FATAL: \$SD is NOT a PDF::GraphPaper::Classes::SData";
    }
    if $vscale.defined and $vscale ~~ Bool {
        if $vscale and not $SD.defined {
            ++$err;
            note "FATAL: \$vscale is True but \$SD is NOT defined";
        }

    }

    if $err {
        my $s = $err > 1 ?? "s" !! "";
        note "        exiting with $err fatal error$s";
        exit;
    }
}

sub text-line(
    # caller provides the $page to mark on
    :$page!,
    :$gp!, # the GPaper object
    :$media = "Letter", # paper type
    :$debug,
    ) is export {
    check-inputs :$page, :$gp;
}

sub create-graph-paper(
    # the main calling sub
    #   calls subs 'create-scales' and 'create-grid', as required
    # caller provides the $page to mark on
    :$page!,
    :$gp!, # the GPaper object
    :$SD,  # the SData object, if any, it must exist for any scales
           #   to be generated
    Bool :$vscale = False,   # pass to the appropriate called subs
    Str  :$media = "Letter", # paper type
    :$debug,
    ) is export {

    check-inputs :$page, :$gp, :$SD, :$vscale;

    #===============================================================
    # Determine maximum horizontal and vertical grid squares
    # (or cells if no grids are desired) for the desired paper,
    # orientation, cell-size, and  margins.
    #===============================================================
    # defaults (with limited user inputs via the $gp object for now):
    my $page-width  = $gp.page-width; #  8.5 * 72;
    my $page-height = $gp.page-height; #11.0 * 72;

    # the 4 default margins from $gp
    # their default allows for custom margins for each edge
    # has $.margin-t is rw = -1; # -1 indicates not set
    # has $.margin-b is rw = -1; # -1 indicates not set
    # has $.margin-l is rw = -1; # -1 indicates not set
    # has $.margin-r is rw = -1; # -1 indicates not set

    # define the current margins
    my ($Tm, $Bm, $Lm, $Rm);
    $Tm = $gp.margin-t > -1 ?? $gp.margin-t !! $gp.margins;
    $Bm = $gp.margin-b > -1 ?? $gp.margin-b !! $gp.margins;
    $Lm = $gp.margin-l > -1 ?? $gp.margin-l !! $gp.margins;
    $Rm = $gp.margin-r > -1 ?? $gp.margin-r !! $gp.margins;

    my $max-graph-width  = $page-width  - ($Lm + $Rm);
    my $max-graph-height = $page-height - ($Tm + $Bm);

    say "DEBUG: max-graph-width  = $max-graph-width" if $debug;
    say "DEBUG: max-graph-height = $max-graph-height" if $debug;

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

    # Calculate the desired lower-left corner of the grid area
    # (which also defines the "base" lines for any scales)
    my $mid-point-x = 0.5 * $graph-width;
    my $mid-point-y = 0.5 * $graph-height;

    # THESE TWO POINTS MUST BE PASSED TO THE TWO USING SUBS
    my $LLX = 0 + (0.5 * $page-width)  - (0.5 * $graph-width);
    my $LLY = 0 + (0.5 * $page-height) - (0.5 * $graph-height);

    # define more page parameters to ease creating independent
    # subroutines
    my $GD = GData.new(
        :ncells-x($ncells-x),
        :ncells-y($ncells-y),
        :major-grids($gp.major-grids),
        :cell-size-y($gp.cell-size-y),
        :cell-size-x($gp.cell-size-x),
        :cell-linewidth($gp.cell-linewidth),
        :mid-grid-linewidth($gp.mid-grid-linewidth),
        :grid-linewidth($gp.grid-linewidth),
        :graph-width($graph-width),
        :graph-height($graph-height),
    );

    # if $vscale is True, draw just the vertical scale with
    # left margin as desired
    if $vscale {
        ; # ok for now
    }

    #========================
    # draw any scales desired
    #========================
    # create-scales
    # if $vscale, we skip creating the grid and finish the page
    create-scales :$page, :$gp, :$GD, :$SD, :$LLX, :$LLY, :$debug;
    return if $vscale;

    #==============
    # draw the grid
    #==============
    # create-grid
    create-grid :$page, :$gp, :$GD, :$LLX, :$LLY, :$debug;

} # sub create-graph-paper

# create-grid :$page, :$gp, :$GD, :$LLX, :$LLY;
sub create-grid(
      :$page!,
      :$gp!,
      :$GD!,
      :$LLX!,
      :$LLY!,
      :$debug,
    ) is export {
    check-inputs :$page, :$gp, :$GD;

    # for horizontal scales
        # for top numbers and tick marks
        # for bottom numbers and tick marks
    # for vertical scales
        # for left side numbers and tick marks
        # for right side numbers and tick marks

    $page.graphics: {
        .transform: :translate($LLX, $LLY);

        # draw horizontal lines, $y is varying 0 to $twidth
        #   bottom to top
        for 0..$GD.ncells-y -> $i {
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
            .MoveTo: 0,               $y;
            .LineTo: $GD.graph-width, $y;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$gp.cell-linewidth}" if $debug;

        # draw vertical lines, $x is varying 0 to $twidth
        #   left to right
        for 0..$GD.ncells-x -> $i {
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
            .LineTo: $x, $GD.graph-height;
            .Stroke;
        }

        say "DEBUG: Grid LineWidth = {$gp.cell-linewidth}" if $debug;
    }
}

sub create-scales(
    :$page!,
    :$gp!, # the GPaper obj
    :$GD!, # the GData  obj
    :$SD!, # the SData  obj
    :$LLX!,
    :$LLY!,
    Bool :$vscale = False,
    :$debug,
    ) is export {
    check-inputs :$page, :$gp, :$GD, :$SD;

    my $font = %fonts<t>;
    my $font-size = 12;

    # for horizontal scales
        # for top numbers and tick marks
        # for bottom numbers and tick marks
    # for vertical scales
        # for left side numbers and tick marks
        # for right side numbers and tick marks

    # get all dimens necessary so we can
    # use subs without the $gp, $GD, or $SD objects
    $page.graphics: {
        # always start at the bottom left
        .transform: :translate($LLX, $LLY);

        # then we go to the appropriate sub and translate
        # as needed for that scale
        # where we start depends on which side we are doing

        if $vscale {
            create-left-scale :$page, :$debug, :$vscale,
            :$gp, $GD, $SD, :$font, :$font-size;
           # then quit
        }

        =begin comment
        # left
        if $gp.margins or $gp.margin-l > -1 {
            create-left-scale :$page, :$debug;
        }
        # right
        if $gp.margins or $gp.margin-r > -1 {
            create-right-scale :$page, :$debug;
        }
        # top
        if $gp.margins or $gp.margin-t > -1 {
            create-top-scale :$page, :$debug;
        }
        # bottom
        if $gp.margins or $gp.margin-b > -1 {
            create-bottom-scale :$page, :$debug;
        }
        =end comment

        =begin comment
        #   left to right
        for 0..$GD.ncells-x -> $i {
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
            .LineTo: $x, $GD.graph-height;
            .Stroke;
        }
        =end comment
    }
}

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

# create-left-scale :$page, :$debug, :$vscale,
# :$gp, $GD, $SD, :$font, :$font-size;
sub create-left-scale(
    :$page!,
    :$gp!, # the GPaper obj
    :$GD!, # the GData  obj
    :$SD!, # the SData  obj
    :$font!,
    :$font-size!,
    :$vscale!,
    :$debug,
) is export {

    my $llx;
    my $lly;
    if $vscale {
        $llx = 36;
        $lly = 0;
    }
    else {
        $llx = 0;
        $lly = 0;
    }
    
    # standard linewidths in PS points
    # mid-grid line only for even number of cells-per-grid
    # has $.cell-linewidth     is rw = 0;    # very fine line
    # has $.mid-grid-linewidth is rw = 0.75; # heavier line width (for even cpg)
    # has $.grid-linewidth is rw     = 1.40; # heavier line width

    # tick thicknesses (widths)
    my $tic-thick0  = 0;
    my $tic-thick5  = 0.75;
    my $tic-thick10 = 1.40;
    # tick lengths
    my $tic-length0  = 0;
    my $tic-length5  = 0.75;
    my $tic-length10 = 1.40;
   
    my $height = $gp.page-height;
    $page.graphics: {
        .transform: :translate($llx, $lly);
        # VERTICAL line
        .LineWidth = 0.7; # ?$gp.cell-linewidth;
        .MoveTo: 0, 0;
        .LineTo: 0, $height; ## page height$ury, $GD.graph-height;
        .Stroke;

        # tick marks and numbers
        .MoveTo: 0, 0;
        my $y = 0;
        my $inc = 0.1 * $gp.units; 
        my $tick-angle = 0; # degrees
        my $tnum = 0;
        my ($width, $length);
        my $scale-number = 0; # for the scale markings
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

            draw-line :$page, :angle($tick-angle), :x($llx), :$y, 
                              :$width, :$length;

            if $put-scale-number {
                my $delta-x = 2 + $tic-length10;
                print-scale-number :$page, :x($delta-x), :$y, :$font, 
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
    }

    =begin comment
    #   left to right
    for 0..$GD.ncells-x -> $i {
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
        .LineTo: $x, $GD.graph-height;
        .Stroke;
    }
    =end comment
} # end of sub create-left-scale

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
                     of a page with default X=0.5in and Y=0in

    HERE
}

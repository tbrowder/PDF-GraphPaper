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

my $pdf-cnf = "{%*ENV<HOME>}/pdf-graphpaper.cnf".IO // "";
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
    $code is copy where $code ~~ /:i 
        letter | legal | a0 | a1 | a2 | a3 | a4 | a5 | b4 | b5 |
        executive | ledger | folio | quarto | statement | tabloid 
        /;
    :$debug,
    --> List
    ) is export {

    #--> List # llx, lly, urx, ury (PS points)
    with $code {
        when /letter/ { 0, 0, 0, 0 };
        when /legal/ { 0, 0, 0, 0 }; 
        when /a0/  { 0, 0, 0, 0 }; 
        when /a1/ { 0, 0, 0, 0 }; 
        when /a2/ { 0, 0, 0, 0 }; 
        when /a3/   { 0, 0, 0, 0 }; 
        when /a4/   { 0, 0, 0, 0 }; 
        when /a5/   { 0, 0, 0, 0 }; 
        when /b4/   { 0, 0, 0, 0 }; 
        when /b5/  { 0, 0, 0, 0 }; 
        when /executive/   { 0, 0, 0, 0 }; 
        when /ledger/   { 0, 0, 0, 0 }; 
        when /folio/   { 0, 0, 0, 0 }; 
        when /quarto/   { 0, 0, 0, 0 }; 
        when /statement/   { 0, 0, 0, 0 }; 
        when /tabloid/ { 0, 0, 0, 0 }; 

        default { 0, 0, 0, 0 }; 
    }

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

sub deg2rad($degrees) is export {
    $degrees * pi / 180
}

sub rad2deg($radians) is export {
    $radians * 180 / pi
}

sub create-grid(
    :$page!,
    :$gp!, #
    :$code = "Letter",
    :$debug,
    ) is export {

    #===============================================================
    # Determine maximum horizontal and vertical grid squares
    # (or cells if no grids are desired) for the desired paper,
    # orientation, cell-size, and  margins.
    #===============================================================
    # defaults (with limited user inputs via the $np object for now):
    my $page-width  =  8.5 * 72; # <= should be done in TWEAK
    my $page-height = 11.0 * 72; # <= should be done in TWEAK
    # individual margin settings should be done in TWEAK

    my $max-graph-width  = $page-width  - $gp.margins * 2;
    my $max-graph-height = $page-height - $gp.margins * 2;
    say "DEBUG: max-graph-width = $max-graph-width" if $debug;
    say "DEBUG: \$gp.cell-size-x: {$gp.cell-size-x}" if $debug;
    say "DEBUG: \$gp.cell-size-y: {$gp.cell-size-y}" if $debug;

    my $max-ncells-x = floor($max-graph-width  / $gp.cell-size-x);
    my $max-ncells-y = floor($max-graph-height / $gp.cell-size-y);

    say "DEBUG: \$max-ncells-x: {$max-ncells-x}" if $debug;

    my $ngrids-x = $gp.major-grids
                   ?? floor($max-ncells-x div $gp.cells-per-grid)
                   !! 0;
    my $ngrids-y = $gp.major-grids
                   ?? floor($max-ncells-y div $gp.cells-per-grid)
                   !! 0;
    my $ncells-x = $ngrids-x
                   ?? ($ngrids-x * $gp.cells-per-grid)
                   !! $max-ncells-x;
    my $ncells-y = $ngrids-y
                   ?? ($ngrids-y * $gp.cells-per-grid)
                   !! $max-ncells-y;
    my $graph-size-width = $gp.major-grids
               ?? ($ngrids-x * $gp.cells-per-grid * $gp.cell-size-x)
               !! ($ncells-x * $gp.cell-size-x);
    my $graph-size-height = $gp.major-grids
               ?? ($ngrids-y * $gp.cells-per-grid * $gp.cell-size-y)
               !! ($ncells-y * $gp.cell-size-y);

    if $debug {
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

=begin comment
    # caller should do this:
    my $pdf  = PDF::Lite.new;
    $pdf.media-box = 0, 0, $page-width, $page-height;
    my $page = $pdf.add-page;
=end comment

#=begin comment

    # Translate to the lower-left corner of the grid area
    my $llx = 0 + 0.5 * $page-width - 0.5 * $graph-size-width;
    my $lly = $page-height - 72 - $graph-size-height;

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
            .MoveTo: 0,                 $y;
            .LineTo: $graph-size-width, $y;
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
            .LineTo: $x, $graph-size-height;
            .Stroke;
        }
        say "DEBUG: Grid LineWidth = {$gp.cell-linewidth}" if $debug;
    }
#=end comment

=begin comment
    # caller should do this:
    $pdf.save-as: $ofil;
    say "See output file: '$ofil'";
=end comment
} # sub create-grid

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
    =end comment

    my $debug = 0;
    my $show-spec = 0;
    my $spec;
    my $vscale = 0;
    my $force = 0;
    my $ofil;

    my $exe = 0;

    for @args {
        when /:i '.pdf' $/ {
            $ofil = $_.IO;
            ++$exe;
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
            $exe = 1;
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
        say "show-spec: not yet implepented...";
#       create-spec-file $ofil, :$debug;
    }
    elsif $exe {
        say "Create output file: Not yet implepented...";
        # creates a pdf file and calls sub create-grid with it
#       create-gridded-file $ofil, :$debug;
    }
    elsif $force {
        say "Added the 'force' option for overwriting files";
    }
    else {
        say "FATAL: Unexpected arg '$_'";
        exit;
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

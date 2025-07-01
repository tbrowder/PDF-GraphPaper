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
    say "DEBUG: \$gp.cell-size-x: {$gp.cell-size-x}";
    say "DEBUG: \$gp.cell-size-y: {$gp.cell-size-y}";

    my $max-ncells-x = floor($max-graph-width  / $gp.cell-size-x);
    my $max-ncells-y = floor($max-graph-height / $gp.cell-size-y);

#   $gp.major-grids = True;
    my $ngrids-x = $gp.major-grids
                   ?? floor($gp.$max-ncells-x div $gp.cells-per-grid)
                   !! 0;
    my $ngrids-y = $gp.major-grids
                   ?? floor($gp.$max-ncells-y div $gp.cells-per-grid)
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
        my $cpgx = $gp.cells-per-grid-x;
        my $cpgy = $gp.cells-per-grid-y;
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

=begin comment
    # caller should do this:
    $pdf.save-as: $ofil;
    say "See output file: '$ofil'";
=end comment
} # sub create-grid

sub run(@args) is export {
    say "Executing {$*PROGRAM.basename}...";
    # input vars for run
    my $debug = 0;
    my $ofil;
    my $ifil;
    my $spec = 0;

    my $exe = 0;
    for @args {
        when /^:i sp / {
            # create the default spec file
            ++$spec;
        }
        when /^:i in '=' (\S+)  / {
            # read the input spec file
            $ifil = ~$0;
            unless $ifil.IO.r {
                say "FATAL: Unable to read config file '$ifil'";
                say "Exiting...";
                exit;
            }
            $exe = 1;
        }
        when /^:i out '=' (\S+)  / {
            # the output gridded file
            $ofil = ~$0;
            unless $ofil.IO.w {
                say "FATAL: Unable to write config file '$ofil'";
                say "Exiting...";
                exit;
            }
            $exe = 1;
        }
        when /^:i d / {
            ++$debug;
        }
        default {
            say "FATAL: Unknown arg '$_'";
            say "Exiting...";
            exit;
        }
    }

    # handle the args
    if $spec {
        say "Not yet implepented...exiting"; exit;
#       create-spec-file $ofil, :$debug;
    }
    elsif $exe {
        say "Not yet implepented...exiting"; exit;
        # creates a pdf file and calls sub create-grid with it
#       create-gridded-file $ofil, :$debug;
    }

}

sub help is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode> [options...]

    Creates a gridded overlay on single page according
    to the user's specification in a configuration file.

    Modes:
      in=X - Where X is a specification file name
      spec - Creates a specification file on STDOUT

    Options:
      out=Y - Where Y is the name of the output PDF file
              (overrides the name in the input file)
    HERE
}

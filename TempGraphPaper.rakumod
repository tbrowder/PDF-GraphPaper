# used to store old code while making drastic changes
# reorganization

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

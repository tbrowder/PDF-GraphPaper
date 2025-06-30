unit class PDF::GraphPaper::GPaper;

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

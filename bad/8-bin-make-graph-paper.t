use Test;

use PDF::GraphPaper;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;
use PDF::GraphPaper::Classes;

my ($ofil, $res);
lives-ok {
    show-paper-sizes
}

lives-ok {
    $res = get-paper-dimens 'letter'
}
is $res, '0 0 612 792';

lives-ok {
    $ofil = "test.pdf";
    #my $p = PDF::GraphPaper::GPaper.new;
    my $gp = GPaper.new;
    run "bin/make-graph-paper", $ofil, :debug(1);
}, "default graph paper";

lives-ok {
    $ofil = "test2.pdf";
    my $gp = GPaper.new;
   
    $gp.major-grids = 0;
    $gp.cell-size = 1; # input in inches
    $gp.cells-per-grid = 0;
    run "bin/make-graph-paper", $ofil, :$gp, :debug(1);
}, "customized graph paper";

done-testing;

=finish

ok 1 - The object is-a 'PDF::GraphPaper::Classes::GPaper'
# Current list of 24 attributes and values:
units               in
media               letter
orientation         portrait
margins             36
margin-t            -1
margin-b            -1
margin-l            -1
margin-r            -1
cell-size-x         7.2
cell-size-y         7.2
page-width          612
page-height         792
major-grids         True
minor-grids         True
cells-per-grid      10
cell-linewidth      0
mid-grid-linewidth  0.75
grid-linewidth      1.4
scale-t             0
scale-b             0
scale-l             0
scale-r             0
grid-origin-x       0
grid-origin-y       0
1..1

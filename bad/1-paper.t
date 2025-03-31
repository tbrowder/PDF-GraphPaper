use Test;

use PDF::GraphPaper;

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
    my $p = PDF::GraphPaper::GPaper.new;
    make-graph-paper $ofil, :$p, :debug(1);
}, "default graph paper";

lives-ok {
    $ofil = "test2.pdf";
    my $p = PDF::GraphPaper::GPaper.new;
    $p.major-grids = 0;
    $p.cell-size = 1; # input in inches
    $p.cells-per-grid = 0;
    make-graph-paper $ofil, :$p, :debug(1);
}, "customized graph paper";

done-testing;

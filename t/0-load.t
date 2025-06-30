use Test;

use PDF::GraphPaper;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;
use PDF::GraphPaper::GPaper;

isa-ok PDF::GraphPaper, PDF::GraphPaper;
isa-ok PDF::GraphPaper::GPaper, PDF::GraphPaper::GPaper;
isa-ok PDF::GraphPaper::Subs, PDF::GraphPaper::Subs;
isa-ok PDF::GraphPaper::Vars, PDF::GraphPaper::Vars;

done-testing;

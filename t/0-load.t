use Test;

use PDF::GraphPaper;
use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;

isa-ok PDF::GraphPaper, PDF::GraphPaper;
isa-ok PDF::GraphPaper::Subs, PDF::GraphPaper::Subs;
isa-ok PDF::GraphPaper::Vars, PDF::GraphPaper::Vars;

done-testing;

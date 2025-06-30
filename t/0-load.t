use Test;

my @modules = <
    PDF::GraphPaper;
    PDF::GraphPaper::Subs;
    PDF::GraphPaper::Vars;
    PDF::GraphPaper::GPaper;
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}

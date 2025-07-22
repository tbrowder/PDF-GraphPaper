use Test;

my @modules = <
    PDF::GraphPaper;
    PDF::GraphPaper::FreeFonts;
    PDF::GraphPaper::Subs;
    PDF::GraphPaper::Vars;
    PDF::GraphPaper::Classes;
>;

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}

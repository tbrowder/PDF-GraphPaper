unit module PDF::GraphPaper::Subs;

use PDF::GraphPaper::Vars;

sub is-odd(Int $num --> Bool) is export {
    if $num div 2 == 1 {
        return True
    }
    False
}

sub create-spec-file(
    $ofil?, 
    :$debug
    ) is export {
}

sub create-gridded-file(
    # creates a pdf file and calls sub create-grid with it
    $ofil?,
    :$debug,
    ) is export {
}

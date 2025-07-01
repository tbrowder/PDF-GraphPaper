unit module PDF::GraphPaper::Subs;

use PDF::GraphPaper::Vars;

sub is-odd(Int $num) is export {
    if $num % 2 == 1 {
        return True;
    }
    else {
        return False;
    }
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

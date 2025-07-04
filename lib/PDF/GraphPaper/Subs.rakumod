unit module PDF::GraphPaper::Subs;

use Text::Utils :ALL;
use PDF::GraphPaper::Vars;

sub read-specs-file(
    IO::Path $fil, 
    --> Array) is export {
    # reads class attr data from an external file
    # to set changed attrs
    # line format: "key value"
    my @lines;
    for $fil.IO.lines -> $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;
        @lines.push: $line;
    }
}

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

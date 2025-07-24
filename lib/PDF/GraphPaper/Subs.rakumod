unit module PDF::GraphPaper::Subs;

use MacOS::NativeLib "*";
use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;
use PDF::Content::XObject;
use PDF::Tags;
use PDF::Content::Text::Box;
use PDF::Content::Page :PageSizes;

use Text::Utils :ALL;

use PDF::GraphPaper::Vars;

# print-scale-number-in-situ :$page, :x($delta-x), :$y, :$font, 
#                            :$font-size; # add angle and color
sub print-scale-number-in-situ(
    :$page!, 
    :$x!, 
    :$y!, 
    :$font!, 
    :$font-size!, # add optional angle and color
    :$angle = 90,
    ) is export {
}

# draw-line-in-situ :$page, :angle(), :x(), y(), :length(), :width();
sub draw-line-in-situ(
    :$page!, 
    :$angle!, 
    :$x!, 
    :$y!, 
    :$length!, 
    :$width!;
    :$debug,
) is export {
    # the line's x=0 and y=0 are at the desired rotation point
    # the line's angle regerence is horizontal at zero, positive increasing
    #   counter-clockwise

}
 
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

sub deg2rad($degrees) is export {
    $degrees * pi / 180
}

sub rad2deg($radians) is export {
    $radians * 180 / pi
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

sub get-paper-dimens(
    $code is copy where $code ~~ /:i
        letter | legal | a0 | a1 | a2 | a3 | a4 | a5 | b4 | b5 |
        executive | ledger | folio | quarto | statement | tabloid
        /;
    :$debug,
    --> List
    ) is export {

    #--> List # llx, lly, urx, ury (PS points)
    with $code {
        when /letter/ { 0, 0, 0, 0 };
        when /legal/ { 0, 0, 0, 0 };
        when /a0/  { 0, 0, 0, 0 };
        when /a1/ { 0, 0, 0, 0 };
        when /a2/ { 0, 0, 0, 0 };
        when /a3/   { 0, 0, 0, 0 };
        when /a4/   { 0, 0, 0, 0 };
        when /a5/   { 0, 0, 0, 0 };
        when /b4/   { 0, 0, 0, 0 };
        when /b5/  { 0, 0, 0, 0 };
        when /executive/   { 0, 0, 0, 0 };
        when /ledger/   { 0, 0, 0, 0 };
        when /folio/   { 0, 0, 0, 0 };
        when /quarto/   { 0, 0, 0, 0 };
        when /statement/   { 0, 0, 0, 0 };
        when /tabloid/ { 0, 0, 0, 0 };

        default { 0, 0, 0, 0 };
    }

    my %h;
    $code .= tc;
    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
        %h{$k} = [$v];
    }
    for %h.keys.sort -> $k {
        my $v = %h{$k};
        say "  $k: $v" if $debug;
    }
    my $size;
    if %h{$code}:exists {
        $size = %h{$code};
        say "Paper code '$code' size (PS points):" if $debug;
        say "  $size" if $debug;
    }
    else {
        $size = "Unrecognized paper code '$code'";
        say "unrecognized paper code '$code'" if $debug;
    }
    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
    }
    $size;
} # get-paper-dimens


sub show-paper-sizes(
    :$debug,
    --> List
) is export {
    say "Known paper sizes (PS points):";
    my %h;
    for PageSizes.kv -> $k, $v {
        say "$k, $v" if $debug;
        %h{$k} = [$v];
    }
    for %h.keys.sort -> $k {
        my $v = %h{$k};
        say "  $k: $v";
    }
}

=begin comment
sub create-right-scale(
    :$page!,
    :$debug,
    ) is export {
} # end of sub

sub create-top-scale(
    :$page!,
    :$debug,
    ) is export {
} # end of sub

sub create-bottom-scale(
    :$page!,
    :$debug,
    ) is export {
} # end of sub
=end comment

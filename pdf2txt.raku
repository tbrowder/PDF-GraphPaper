#!/usr/bin/env raku
#      Uncompress PDF page streams for editing the PDF in a text editor (e.g.,
#      vim, emacs)
#        pdftk doc.pdf output doc.unc.pdf uncompress

#      This is a port of pdftk to java. See
#      https://gitlab.com/pdftk-java/pdftk
#      The original program can be found at www.pdftk.com

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <input pdf> <output txt>

    Uses 'pdftk' to uncompress the pdf file.
    HERE
    exit;
}

my $pdfin  = @*ARGS.shift;
my $txtout = "{$pdfin}.txt";
if @*ARGS  {
    $txtout = @*ARGS.shift;
}
if $pdfin eq $txtout {
    say "FATAL: Input and output files are the same...exiting";
}

run "pdftk", "$pdfin", "output", "$uncpdf", "uncompress";

say "See output text file: $txtout";

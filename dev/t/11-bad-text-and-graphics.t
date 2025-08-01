use Test;

my $debug = 1;
my $ofil = "test11.pdf";

# use required libs
use MacOS::NativeLib "*";
#use PDF::API6;
use PDF::Lite;

#use PDF::Content::Color :ColorName, :color;
#use PDF::Tags;
#use PDF::Content::Text::Box;
#use PDF::Content::Ops :TextMode;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
isa-ok $page, PDF::Lite::Page;

sub mixed{...}

my $font = $pdf.core-font(:family<Times-Roman>);

my $text = "Some text";
lives-ok {
    mixed $text, :$font;
}

done-testing;

if $debug {
    $pdf.save-as: $ofil;
    say "DEBUG: See output file '$ofil'";
}

sub mixed(
    $text,
    :$llx = 0,
    :$lly = 0,
    :$font!,
    :$font-size = 12,
) {

    my $tx = -20;
    my $ty = -20;

    $page.graphics: {
        .transform: :translate($llx+200, $lly+500);
        .MoveTo: 0, 0;
        .LineTo: 200, 0;
        .CloseStroke;

        .text: {
            .font = $font, $font-size;
            .text-position = $tx, $ty;
            .print: $text, :align<left>, :valign<center>;
        }
    }
}

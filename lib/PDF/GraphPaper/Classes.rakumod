unit module PDF::GraphPaper::Classes;

use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;

role Data {
    # 18 attributes with default values, in desired order
    has $.units is rw       = "in";       # default
    has $.media is rw       = "letter";   # default
    has $.orientation is rw = "portrait"; # default
    #=========================
    #== defaults for Letter paper
    has $.margins is rw       = 0.5 * 72;
    # allow for custom margins for each edge
    has $.margin-t is rw = -1; # -1 indicates not set
    has $.margin-b is rw = -1; # -1 indicates not set
    has $.margin-l is rw = -1; # -1 indicates not set
    has $.margin-r is rw = -1; # -1 indicates not set

    has $.cell-size-x is rw =  0.1 * 72; # desired minimum cell
                                     #   size (inches)
    has $.cell-size-y is rw =  0.1 * 72; # desired minimum cell
                                     #   size (inches)
    has $.page-width  is rw =  8.5 * 72;
    has $.page-height is rw = 11.0 * 72;

    has $.major-grids is rw = True;
    has $.minor-grids is rw = True;  # forced False if cells-per-grid
                                     #   is odd
    has $.cells-per-grid is rw = 10; # heavier line every X cells

    # standard linewidths in PS points
    # TODO allow customization
    # mid-grid line only for even number of cells-per-grid
    has $.cell-linewidth     is rw = 0;    # very fine line
    has $.mid-grid-linewidth is rw = 0.75; # heavier line width
                                           #  (for even cpg)
    has $.grid-linewidth is rw     = 1.40; # heavier line width
}

class GPaper does Data is export {

    # an array of Data attr names and current values as word pairs
    has @!data;

    submethod TWEAK {
        # attribute names in desired order
        # use @valid-keys from Vars;
        # an array of attr names and current values as word pairs

        # fill the data array with its attr names and current values
        =begin comment
        @!data = 
            "foo $!foo",
            "bar $!bar",
        ;
        =end comment
        # current attribute values;
        my $alen = 0;
        for @valid-keys.kv -> $i is copy, $attr {
            my $data = "$attr $!attr"
            @!data.push: $data;
            my $len = $attr.chars;
            $alen = $len if $len > $alen;
        }
        for @attributes -> $a {
            my $v = %attrs{$a};
            say sprintf '%*.*s', $alen, $alen, $a, " $v";,
        }
        # attributes in desired order
        my @attributes = @valid-keys;
        # a hash of attrs and current values
        my %attrs;

        # current attribute values;
        my @attrs = self.^attributes;
        my $alen = 0;
        for @attrs -> $a {
            my $val = $a.get_value: self;
            %attrs{$a} = $val;
            my $len = $a.chars;
            $alen = $len if $len > $alen;
        }
        for @attributes -> $a {
            my $v = %attrs{$a};
            say sprintf '%*.*s', $alen, $alen, $a, " $v";,
        }
        # attributes in desired order
        my @attributes = @valid-keys;
        # a hash of attrs and current values
        my %attrs;

        # current attribute values;
        my @attrs = self.^attributes;
        my $alen = 0;
        for @attrs -> $a {
            my $val = $a.get_value: self;
            %attrs{$a} = $val;
            my $len = $a.chars;
            $alen = $len if $len > $alen;
        }
        for @attributes -> $a {
            my $v = %attrs{$a};
            say sprintf '%*.*s', $alen, $alen, $a, " $v";,
        }
        if is-odd($!cells-per-grid) {
            $!minor-grids = False; # forced False
        }

        # generate data to enable various queries in
        # a certain order

        # attributes in desired order
        my @attributes = @valid-keys;
        # a hash of attrs and current values
        my %attrs;

        # current attribute values;
        my @attrs = self.^attributes;
        my $alen = 0;
        for @attrs -> $a {
            my $val = $a.get_value: self;
            %attrs{$a} = $val;
            my $len = $a.chars;
            $alen = $len if $len > $alen;
        }
        for @attributes -> $a {
            my $v = %attrs{$a};
            say sprintf '%*.*s', $alen, $alen, $a, " $v";,
        }
    }

    method attrs(--> Hash) {
        # the hash:
        #   key: lower-case key in desired order
        #      value: attr name, attr value
    }

    method is-valid-key($key --> Bool) {
        if %valid-keys{$key}:exists {
            return True;
        }
        False
    }

    method show-spec {
        # attributes in desired order
        my @attributes = @valid-keys;
        # a hash of attrs and current values
        my %attrs;

        # current attribute values;
        my @attrs = self.^attributes;
        my $alen = 0;
        for @attrs -> $a {
            my $val = $a.get_value: self;
            %attrs{$a} = $val;
            my $len = $a.chars;
            $alen = $len if $len > $alen;
        }
        for @attributes -> $a {
            my $v = %attrs{$a};
            say sprintf '%*.*s', $alen, $alen, $a, " $v";,
        }
    }

} # end of exported class GPaper

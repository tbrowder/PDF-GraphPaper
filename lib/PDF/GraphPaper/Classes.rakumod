unit module PDF::GraphPaper::Classes;

use PDF::GraphPaper::Subs;
use PDF::GraphPaper::Vars;

role DefaultAttributes {
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

class GPaper does DefaultAttributes is export {

    # an array of attribute names and current values as word pairs
    has @.attrs;
    has %.attr; 

    submethod TWEAK {
        # attribute names in desired order
        # use @valid-keys from Vars;
        # an array of attr names and current values as word pairs

        # fill the attrs array with its attr names and current values
        # fill the attr hash by name and value for easy lookup

        # current attribute values from the role:
        my @role-attrs = self.^attributes;
        for @role-attrs -> $a {
            my $val = $a.get_value: self;
            my $data = "$a $val";
            if 0 {
                note "DEBUG: curr attr: $a";
                note "         attr val: $val";
            }
            # fill @.attrs
            @!attrs.push: $data;
            # fill %.attr
            %!attr{$a} = $val;
        }

        =begin comment
        @!attrs =
            "foo $!foo",
            "bar $!bar",
        ;
        =end comment
        =begin comment
        # current attribute values;
        my $alen = 0;
        for @valid-keys.kv -> $i is copy, $attr {
            my $data = "$attr $!attr";
            @!attrs.push: $data;
#           %!attr{$attr} = $!attr;
            my $len = $attr.chars;
            $alen = $len if $len > $alen;
        }

        say "DEBUG: attrs and current values:";
        for @!attrs -> $s {
            my $a = $s.words.head;  
            my $v = $s.words.tail;  
            say sprintf '%*.*s  s', $alen, $alen, $a, " $v";
        }
        =end comment

        =begin comment
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
        =end comment
    }

    method attrs(--> Hash) {
        # the hash:
        #   key: lower-case key in desired order
        #      value: attr name, attr value
    }

    =begin comment
    method is-valid-key($key --> Bool) {
        if %valid-keys{$key}:exists {
            return True;
        }
        False
    }
    =end comment

    =begin comment
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
            say sprintf '%*.*s  %s', $alen, $alen, $a, $v;
        }
    }
    =end comment

} # end of exported class GPaper

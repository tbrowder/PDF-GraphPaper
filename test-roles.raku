#!/usr/bin/env raku
role Data {
    has $.foo = 2;
    has $.bar = 3;
}

class Bar does Data {
    has @.data;
    submethod TWEAK {
        # fill the data array with its attr names and current values
        @!data = 
            "foo $!foo",
            "bar $!bar",
        ;
    }
}

class Foo does Data {
    has %.data;
    submethod TWEAK {
        %!data = %(
            a => { foo => $!foo},
            b => { bar => $!bar},
        );
    }
}

say();
say "HASH method";
my $o = Foo.new;
for %($o.data).keys.sort -> $k {
    my $v = %($o.data){$k};
    say "desired order: '$k'";
    my %h2 = %($v);
    for %h2.kv -> $k2, $v2 {
        say "  attr: $k2, value: $v2"; 
    }
}

say();
say "ARRAY method";
$o = Bar.new;
my @arr = @($o.data);

my $alen = 0;
for @arr.kv -> $i is copy, $s {
    ++$i;
    my $a = $s.words.head;
    $alen = $a.chars if $a.chars > $alen;
    my $v = $s.words.tail;
    say "desired order: '$i'";
    say "  attr: $a, value: $v"; 
}

for @arr.kv -> $i is copy, $s {
    my $a = $s.words.head;
    my $v = $s.words.tail;

    say sprintf '%*.*s %s', $alen, $alen, $a, " $v";
}

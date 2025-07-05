#!/usr/bin/env raku

=begin comment
# from doc search for "set_value"
# method set_value(Mu $obj, Mu \new_val)
#   Binds the value 'new_val' to this attribute of 
#     object $obj.
class A {
    has $!a = 5;
    method speak() { say $!a; }
}
# in line below, [0] is the first attr in the class 
#   definition
my $attr = A.^attributes(:local).[0]; 
my $a = A.new;
$a.speak; # OUTPUT: «5␤»
$attr.set_value($a, 42);
$a.speak; # OUTPUT: «42␤»
=end comment

class Foo is export {
    has $.a is rw = 1;
}

my $o = Foo.new;
say $o.a;
my $attr = $o.^attributes(:local).[0];
$attr.set_value($o, 6);
say $o.a;

#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
RCSID := '$Id: arithmetic.st,v 1.2 2012-02-23 19:15:05-08 - - $'.

execname := '$RCSfile: arithmetic.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.

""
"There are only three precedences in Smalltalk"
"1. unary"
"2. binary - strictly left to right"
"3. keyword"
""

stdout << 'x := 3 + 4 * 5.' << nl.
x := 3 + 4 * 5.
x inspect.
stdout << x << nl.

""
"Smalltalk has extended precision."
""

stdout << 'y1 := 64 raisedTo: 20.' << nl.
y1 := 64 raisedTo: 20.
y1 inspect.
stdout << y1 << nl.

stdout << 'y2 := 6 * 6 raisedTo: 3 * 4.' << nl.
y2 := 6 * 6 raisedTo: 3 * 4.
y2 inspect.
stdout << y2 << nl.

""
"Rational numbers."
""

stdout << 'z := 22/7.' << nl.
z := 22/7.
z inspect.
stdout << z << nl.

"TEST: arithmetic.st"


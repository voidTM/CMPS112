#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: intsort.st,v 1.4 2012-02-23 18:39:46-08 - - $"

nl := Character nl.

sort := SortedCollection new.
sort add: 3; add: 1; add: 4; add: 1; add: 5; add: 9; add: 2; add: 6.
sort inspect.

stdout << 'sort do:' << nl.
sort do: [:int|
   stdout << ' ' << int.
].
stdout << nl.

stdout << 'notEmpty whileTrue:' << nl.
[sort notEmpty] whileTrue: [stdout << ' ' << sort removeFirst].
stdout << nl.

"TEST: intsort.st"


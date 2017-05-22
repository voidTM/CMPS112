#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: collatz.st,v 1.2 2012-02-23 18:57:47-08 - - $"
"http://en.wikipedia.org/wiki/Collatz_conjecture"

Object subclass: Collatz [
   Collatz class >> compute: value [
      |n count|
      n := value.
      count := 0.
      [n > 1] whileTrue: [
         stdout << count << ': ' << n << Character nl.
         count := count + 1.
         n even ifTrue: [n := n / 2]
                ifFalse: [n := n * 3 + 1].
      ].
      stdout << count << ': ' << n << Character nl.
   ]
]

Collatz compute: (Smalltalk arguments at: 1) asInteger.

"TEST: collatz.st 15"


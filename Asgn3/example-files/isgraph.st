#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: isgraph.st,v 1.3 2012-03-07 13:17:54-08 - - $"

"http://www.gnu.org/software/smalltalk/manual-base/html_node/
Character_002dtesting.html#Character_002dtesting"

Character extend [
   isGraph [
      ^ ($! <= self) & (self <= $~)
   ]
]

nl := Character nl.
stdout << $a << ' isGraph = ' << $a isGraph << nl.
stdout << nl << ' isGraph = ' << nl isGraph << nl.


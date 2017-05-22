#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: filein.st,v 1.2 2011-05-12 13:13:20-07 - - $"
execname := '$RCSfile: filein.st,v $' =~ '.*: (.*),v.*' at: 1.
stdout << 'Starting ' << execname << '.'; nl.
FileStream fileIn: 'tree.st'.
stdout << 'Finished ' << execname << '.'; nl.

"TEST: filein.st"


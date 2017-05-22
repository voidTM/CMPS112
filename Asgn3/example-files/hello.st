#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
RCSID := '$Id: hello.st,v 1.10 2012-02-23 17:45:49-08 - - $'.

execname := '$RCSfile: hello.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.

""
"Print a Hello message to stdout and the status to stderr."
"Then exit with status 127."
 comments heres?
 
""

stdout << 'Hello, World!' << nl << RCSID << nl.

status := 127.
stderr << execname << ': ' << 'Quitting with status ' << status << nl.
ObjectMemory quit: status.

"TEST: hello.st"


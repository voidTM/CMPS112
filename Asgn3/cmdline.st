#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: cmdline.st,v 1.8 2011-05-05 20:45:21-07 - - $"
""
"Parse command line arguments"
""

flags := Dictionary new.
   (flags at: $d put: false).
   (flags at: $t put: false).
   (flags at: $c put: false).
   (flags at: $u put: false).


execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.

stdout << 'execname: ' << execname << nl.
stdout << 'version: ' << Smalltalk version << nl.
stdout << 'hostSystem: ' << Smalltalk hostSystem << nl.
stdout << 'arguments: ' << Smalltalk arguments << nl.


"Display arguments as elements of array?"

(1 to: Smalltalk arguments size)
do: [:index |
    'argument[' display.
    index display.
    '] = "' display.
    (Smalltalk arguments at: index) display.
    '"' displayNl.
].

(1 to: Smalltalk getArgc)
do: [:argi |
   'argv[' display.
   argi display.
   '] = "' display.
   (Smalltalk getArgv: argi) display.
   '"' displayNl.
].

argSize := Smalltalk arguments size.
flagF := a.
" program expects hzip.st options file1 file2"
argSize < 2
  ifTrue: [
    stderr << 'Arugment amount mismatch' << nl.
    ObjectMemory quit.
  ] ifFalse: [
   " parse each argument as a tuple 
   of option and arguments"

   Smalltalk arguments: '-t -c -u -d'
   do: [:opt :arg |
      " Do something here to set the options flags "
      'arguments:do: ' display.
      opt displayNl.
      stdout << opt << nl.
      ' ' display.
      arg displayNl.
      "Check set to arguments"
      flags at: opt put: true.
      (opt == $d) ifTrue: [dFlag := true.].
      (opt == $c) ifTrue: [cFlag := true.].
      (opt == $t) ifTrue: [tFlag := true.].
      (opt == $u) ifTrue: [uFlag := true.].
   ]
   ifError: [
      stderr << 'Error: invalid option' << nl.
      ObjectMemory quit.
   ]  
].


flags display.
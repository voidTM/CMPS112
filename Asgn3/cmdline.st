#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: cmdline.st,v 1.8 2011-05-05 20:45:21-07 - - $"
""
"Parse command line arguments"
""

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

"parser maybe functional?"
Smalltalk arguments: '-t -c -u -d'
do: [:opt :arg |
   'arguments:do: ' display.
   opt display.
   ' ' display.
   arg displayNl.
]
ifError: [
   'Error: invalid option' displayNl.
   '--foo'
]

" program expects hzip.st options file1 file2"
Smalltalk arguments size < 2
  ifTrue: [
    stderr << 'Arugment amount mismatch' << nl.
    stderr << 'Expect hzip.st [flags]
               [input file] [output file]' << nl.
    ObjectMemory quit.
  ] ifFalse: [
    Smalltalk arguments: '-t -c -u -d'
    do: [:opt :arg |
      'rguments:do: ' display.
      opt display.
      ' ' display.
      arg displayNl.
    ]
  ]
#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: cmdline.st,v 1.8 2011-05-05 20:45:21-07 - - $"
""
"Parse command line arguments"
""

opflags := Dictionary new.
   (flags at: $d put: false).
   (flags at: $t put: false).
   (flags at: $c put: false).
   (flags at: $u put: false).


execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.

" program expects hzip.st options file1 file2"
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

   | file_count |
   file_count := 0.
   Smalltalk arguments: '-t -c -u -d'
   do: [:opt :arg|
      " Do something here to set the options flags "
      'arguments:do: ' display.
      opt displayNl.
      arg displayNl.
      filename displayNl.      
      opflags at: opt put: true.
      "Check set to arguments"
      (opt = $d) ifTrue: [dflag := true.].
      (opt = $c) ifTrue: [cflag := true.].
      (opt = $t) ifTrue: [tflag := true.].
      (opt = $u) ifTrue: [uflag := true.].

      arg ~= nil
         ifTrue:[
         file_count := file_count + 1.
         file_count = 1
         ifTrue:[
            "should later on open and asign filestream"
            infile := arg.

         ]ifFalse:[
            file_count = 2
            ifTrue:[
            "should later on open and assign filestream"
            outfile := arg.
            ]
          ]
        ]
   ]
   ifError: [
      stderr << 'Error: invalid option' << nl.
      ObjectMemory quit.
   ]  
].

infile ~= nil
  ifTrue:[
    [   
      |rfile|
      rfile := FileStream open: infile
          mode: FileStream read.
      rfile close.
    ] on: SystemExceptions.FileError do: [:signal |
      |errno|
      errno := File errno.
      stdout flush.
      stderr << execname << ': ' << infile << ': '
          << signal messageText << nl.
      stderr flush.
      ObjectMemory quit.
    ]
  ]. 

"UNIT TESTS HERE"
opflags displayNl.

dflag displayNl.
cflag displayNl.
tflag displayNl.
uflag displayNl.
infile displayNl.
outfile displayNl.

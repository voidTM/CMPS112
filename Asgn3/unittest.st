#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: cmdline.st,v 1.8 2011-05-05 20:45:21-07 - - $"
""
"Parse command line arguments"
""

opflags := Dictionary new.
   (opflags at: $d put: false).
   (opflags at: $t put: false).
   (opflags at: $c put: false).
   (opflags at: $u put: false).

freqtable := nil.
|prque|

prque := SortedCollection new.

"ARRAY"
Object subclass: ZeroArray [
   |theArray|

   ZeroArray class >> new [
      self shouldNotImplement.
   ]

   ZeroArray class >> new: size [
      |result|
      result := super new.
      result init: size.
      ^ result
   ]

   init: size [
      theArray := Array new: size.
   ]

   size [
      ^ theArray size.
   ]

   at: index [
      ^ theArray at: index + 1.
   ]

   at: index put: value [
      ^ theArray at: index + 1 put: value.
   ]

   incr: index [
      (self at: index) isNil
         ifTrue: [ self at: index put: 0].
      self at: index put: (self at: index) + 1.
   ]

   keysAndValuesDo: aBlock [
      (0 to: (self size) - 1) do: [:index |
         aBlock value: index value: (self at: index).
      ]
   ]

]



"TREEE"

Object subclass: Leaf [
   |char count|
   char [ ^ char ]
   count [ ^ count ]

   Leaf class >> new [
      self shouldNotImplement
   ]

   Leaf class >> new: aChar count: aCount [
      |result|
      result := super new.
      result setChar: aChar andCount: aCount.
      ^result
   ]

   setChar: aChar andCount: aCount [
      char := aChar.
      count := aCount.
   ]

   <= other [
      ^ (count < other count)
      | ((count = other count) & (char <= other char))
   ]

   printBase: aStream [
      ^ aStream << self class << '(' << char << ',' << count
   ]

   printOn: aStream [
      (self printBase: aStream) << ')'.
   ]

   inorder: visitor prefix: string [
      visitor value: char value: string.
   ]

   binTreeDump: aBitstream [
      aBitstream putBit: 0.
      (1 to: 8) do: [:index|
      aBitstream putBit: ((self char asInteger) bitAt: index)].
      char asInteger = 0 ifTrue:[
        aBitstream putBit: 0.
      ].
      char asInteger = 256 ifTrue:[
        aBistream putBit: 1.
      ].
   ]
]


Leaf subclass: Tree [
   |left right|

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight [
      |result|
      result := super new: aChar count: aCount.
      result setLeft: aLeft andRight: aRight.
      ^ result
   ]

   setLeft: aLeft andRight: aRight [
      left := aLeft.
      right := aRight.
   ]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   inorder: visitor prefix: string [
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'.
   ]

   binTreeDump: aBitstream [
      left binTreeDump: aBitstream.
      right binTreeDump: aBitstream.
      aBitstream putBit: 1.
   ]

]




FileStream extend [
   nl := Character nl.
   
   catFile [
      |count|
      count := 0.
      [self atEnd not] whileTrue: [
         count := count + 1.
         count asString size to: 5 do: [:skip| stdout << ' '].
         stdout << count << ': ' << self nextLine << nl.
      ]
   ]

   parseFile [
      |freqtable|
      freqtable := ZeroArray new: 257.
      [self atEnd not] whileTrue: [
         |ordChar|
         ordChar := self next asInteger.
         freqtable incr: ordChar.
        "ordChar display.
        (ordChar asCharacter) displayNl."
      ].
      freqtable incr: 256.
      ^ freqtable
   ]
]


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

      freqtable := rfile parseFile.

      "enters freqtable into priority queue
       as tree nodes"
      (0 to: freqtable size - 1)
      do: [:index | 
        |cleaf ccount cchar|
        ccount := freqtable at: index.
        ccount isInteger ifTrue:[
            cchar := index asCharacter.
            cleaf := Leaf new: cchar count: ccount.
            prque add: cleaf. 
        ].
      ].

      "construct tree"
      [prque size > 1] whileTrue:[
        |last seclast tree treechar treecount|
        last := prque removeFirst.
        seclast := prque removeFirst.
        treechar := last char.
        treecount := last count + seclast count.
        tree := Tree new: treechar
                    count: treecount
                    left: last
                    right: seclast.
        prque add: tree.
      ].


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

infile displayNl.
outfile displayNl.

(0 to: freqtable size - 1)
do: [:index |
    (freqtable at: index) ~= nil
      ifTrue: [
        stdout << 'Index ' << index << ' '.
        (freqtable at: index) displayNl.
      ]
].


prque display.
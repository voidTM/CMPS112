""
"#! /afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk-3.2.5/bin/gst -f"



" REGEx on first part?"
execname := '$RCSfile: hzip.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.
dflag := false.
cflag := false.
tflag := false.
uflag := false.
infile := nil.
outfile := nil.

huffman_tree := nil.
freqtable := nil.
encodetable := nil.
prque := SortedCollection new.


"------------------------------------------------------"
"Globals"
flags := Dictionary new.
   (flags at: $d put: false).
   (flags at: $t put: false).
   (flags at: $c put: false).
   (flags at: $u put: false).



"------------------------------------------------------"
"arrays?"

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


"------------------------------------------------------"
"Bitstreams"

Character extend [
   isGraph [
      ^ (Character space < self) & (self <= $~)
   ]
   visible [
      self isGraph ifTrue: [^ '$', self asString]
                   ifFalse: [^ self asInteger printStringRadix: 16]
   ]
]

Character extend [
   isGraph [
      ^ (Character space < self) & (self <= $~)
   ]
   visible [
      self isGraph ifTrue: [^ '$', self asString]
                   ifFalse: [^ self asInteger printStringRadix: 16]
   ]
]

Object subclass: BitStream [
   |bitIndex byte myStream|
   BitStream class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   init: fileStream [
      myStream := fileStream.
      bitIndex := 1.
   ]
   nextBit [
      bitIndex = 1 ifTrue: [
         byte := myStream next.
         bitIndex := 9.
      ].
      bitIndex := bitIndex - 1.
      ^byte value bitAt: bitIndex
   ]
   atEnd [
      ^bitIndex = 1 and: [myStream atEnd]
   ]
   currByte [
      ^byte
   ]
]


"------------------------------------------------------"
" Tree based on tree.st"
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

"------------------------------------------------------"
" Compression "
" Count frequency of input char based on charfreq.st"


" FILE I/O?"
"taken from catfile.st"

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

   "Create frequency table"
   parseFile [
      |freqtable|
      freqtable := ZeroArray new: 257.
      [self atEnd not] whileTrue: [
         |ordChar|
         ordChar := self next asInteger.
         freqtable incr: ordChar.
      ].
      freqtable incr: 256.
      ^ freqtable
   ]
]




"------------------------------------------------------"

"Write out encoding table"

tflag ifTrue: [
    (0 to encodetable size - 1)
    do: [:index|
        |char upperbound lowerbound count string|
        lowerbound := index > 32.   "ASCII bigger than SPACE"
        upperbound := index < 127.  "ASCII less than DELETE"
        count := freqtable at: index.
        string := encodetable at: index.
        count isInteger ifTrue: [
            char := index asCharacter.
            stdout << char << ' ' << count << ' ' << string << n1.
        ] ifFalse: [
            stdout << index << ' ' << count << ' ' << string << n1.
        ]. 
    ].
    readfile close.
].


"------------------------------------------------------"
" Uncompressing "
" Read in tree and reconstruct"
" read data bit by bit "



"------------------------------------------------------"
" input and output here "
" mainish "

"Input data"


" program expects hzip.st options file1 file2"
argSize := Smalltalk arguments size.
flagF := a.
argSize < 2
  ifTrue: [
    stderr << 'Arugment amount mismatch' << nl.
      ObjectMemory quit: 1.
  ] ifFalse: [
   " parse each argument as a tuple 
   of option and arguments"

   | file_count |
   file_count := 0.
   Smalltalk arguments: '-t -c -u -d'
   do: [:opt :arg|
      " Do something here to set the options flags "
      flags at: opt put: true.
      flags at: opt put: true.
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
      stderr << 'Error: invalid flag' << nl.
      ObjectMemory quit: 1.
   ]  
].


" operate on infile"
infile ~= nil
  ifTrue:[
   [   
      |rfile wfile|
      rfile := FileStream open: infile
          mode: FileStream read.


      "either compression or tree"
      (tflag | cflag) ifTrue:[
         "Construct frequency table"
         freqtable := rfile parseFile.
         dflag ifTrue:[
            (0 to: freqtable size - 1)
            do: [:index|
               (freqtable at: index) ~= nil
               ifTrue:[
                  stdout << 'Index ' << index << ' '.
                  (freqtable at: index) displayNl.
               ]
            ].
         ].

         rfile close.

         "Iterate over frequency table. 
         insert leaf into priority queue"
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


         "Construct tree using priority queue"
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
         dflag ifTrue: [prque inspect.].


         "remove tree from priority queue"
         huffman_tree := prque removeFirst.

         "Create encoding table"
         encodetable := ZeroArray new: 257.
         huffman_tree inorder: [:char :string |
            |index count|
            index := char asInteger.
            encodetable at: index put: string.
         ] prefix: ''.


         tflag ifTrue:[
            (0 to: encodetable size - 1)
            do: [:index|
            |char count string|
            count := freqtable at: index.
            string := encodetable at: index.
            count isInteger ifTrue:[
               (index < 127) & (index > 32)
               ifTrue:[
                  char := index asCharacter.
                  stdout << char << ' ' << count.
                  stdout << ' ' << string << nl.
               ]ifFalse:[
                  stdout << index << ' ' << count. 
                  stdout << ' ' << string << nl.
               ]
            ]]
         ]ifFalse:[
            |aBitstream estring|
            "Compress the input file"
            cflag ifTrue:[
               " open out file for writing"
               outfile ~= nil
               ifTrue:[
                  wfile := FileStream open: outfile
                  mode: FileStream write.
               ]ifFalse:[ wfile := stdout.].

               rfile := FileStream open: infile
                  mode: FileStream read.

               aBitstream := Bitstream new: wfile.

               "Write out the encoding tree" 
               tree binTreeDump: aBitstream.
               aBitstream putBit: 1.
               [readfile atEnd not] whileTrue:[
                  |index|
                  index := readfile next asInteger.
                  estring := encodetable at: index.
                  aBitstream putString: estring.
               ].
               estring := encodetable at: 256.
               aBitstream putString: estring.
               aBitstream padOut.
               wfile close.
               rfile close.
            ]
         ]
      ]
   ] on: SystemExceptions.FileError do: [:signal |
      |errno|
      errno := File errno.
      stdout flush.
      stderr flush.
      ObjectMemory quit: 1.
    ]
]. 

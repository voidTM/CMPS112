
" REGEx on first part?"
execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.
dflag := false.
cflag := false.
tflag := false.
uflag := false.
infile := ''.
outfile := stdout.


"------------------------------------------------------"
"Globals"
flags := Dictionary new.
   (flags at: '$d' put: false).
   (flags at: '$t' put: false).
   (flags at: '$c' put: false).
   (flags at: '$u' put: false).



"------------------------------------------------------"
"arrays?"


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

]

"------------------------------------------------------"
" Compression "
" Count frequency of input char based on charfreq.st"
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


|readfile writefile|

readfile := FileStream open: infile
                        mode: FileStream read.

writefile := FileStream open: outfile
                        mode: FileStream write.

|freqtable|

uflag ifFalse: [freqtable := readfile parseFile.].

dflag ifTrue:[].

|prque|

"------------------------------------------------------"
" Uncompressing "




"------------------------------------------------------"
" input and output here "
" mainish "

stdout << 'execname: ' << execname << nl.
stdout << 'version: ' << Smalltalk version << nl.
stdout << 'hostSystem: ' << Smalltalk hostSystem << nl.
stdout << 'arguments: ' << Smalltalk arguments << nl.


"  "
(1 to: Smalltalk arguments size)
do: [:index |
    'argument[' display.
    index display.
    '] = "' display.
    (Smalltalk arguments at: index) display.
    '"' displayNl.
].

"  "
(1 to: Smalltalk getArgc)
do: [:argi |
   'argv[' display.
   argi display.
   '] = "' display.
   (Smalltalk getArgv: argi) display.
   '"' displayNl.
].



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

   Smalltalk arguments: '-t -c -u -d'
   do: [:opt :arg |
      " Do something here to set the options flags "
      flags at: opt ifPresent: [flags at: opt put: true].
      'arguments:do: ' display.
      opt displayNl.
      stdout << opt << nl.
      ' ' display.
      arg displayNl.
      flags at: opt put: true.
      "Check set to arguments"
      (opt == $d) ifTrue: [dflag := true.].
      (opt == $c) ifTrue: [cflag := true.].
      (opt == $t) ifTrue: [tflag := true.].
      (opt == $u) ifTrue: [uflag := true.].
   ]
   ifError: [
      stderr << 'Error: invalid option' << nl.
      ObjectMemory quit.
   ]  
].


flags at: $c display.
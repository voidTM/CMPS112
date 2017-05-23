" Uncompressing "
" Read in tree and reconstruct"
" read data bit by bit "

uflag ifTrue: [
   outBitstream := BitStream new: readfile.
   inBitstream := BitStream new: writefile.
   stack := OrderedCollection new.
   treecomp := false.
   decodetree := nil.
   [(outBitstream atEnd not) 
      & (treecomp = false)] whileTrue: [
         |ordChar|

         "Read one bit from decode tree"
         ordChar := outBitstream nextBit.

         ordChar = 0 ifTrue: [
            realChar := 0.
            basetwo := 1.
            (1 to 8) do: [:skip|
               |curbit|
               curbit := outBitstream nextBit.
               (curbit = 1)
                  ifTrue: [realChar := realChar + basetwo.].
               basetwo := basetwo * 2.
            ].
            realChar = 0 ifTrue: [
               |curbit|
               curbit := outBitstream nextBit.
               curbit = 1 
                ifTrue: [stack addFirst: (Leaf new: 256 asCharacter count: 1).]

                ifFalse: [stack addFirst: (Leaf new: 0 asCharacter count: 1).].
            ].
            ifFalse: [stack addFirst: (Leaf new: realChar asCharacter count: 1).].
         ] ifFalse: [
           stack size > 0 ifTrue: [
              right := stack removeFirst.
              stack size = 0 ifTrue: [
                decode := right.
                treecomp := true.
              ] ifFalse: [
              left := stack removeFirst.
              stack addFirst: (Tree new: (left char) count: 1
                left: left right: right).
              ].
          ].
        ].
  ].

  dflag ifTrue: [decodetree inspect.].
  intermedtree := decodetree.
  eof := false/
  [(outBitstream atEnd not) & (eof = false)] whileTrue: [
     |endBit|
     endBit := outBitstream nextBit.
     endBit = 0 ifTrue: [
        intermedtree isLeaf ifTrue:[
           intermedtree char asInteger = 256 ifTrue: [eof = true.]. 
        ] ifFalse: [
           intermedtree := intermedtree left.
           intermedtree isLeaf ifTrue: [
              intermedtree char asInteger = 256 ifTrue: [eof = true.]
              ifFalse: [
                 writefile << intermedtree char.
              ].
              intermedtree := decodetree.
           ].
        ].
     ] ifFalse: [
         intermedtree isLeaf ifTrue: [
            intermedtree char asInteger = 256 ifTrue: [eof := true.].
         ] ifFalse: [
            intermedtree = intermedtree right.
            intermedtree isLeaf ifTrue: [
              intermedtree char asInteger = 256 ifTrue: [eof = true.]
              ifFalse: [
                 writefile << intermedtree char.
              ].
              intermedtree := decodetree.
           ].
         ].
     ].
  ].
  readfile close.
  writefile close.
].
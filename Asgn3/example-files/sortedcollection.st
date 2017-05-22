#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: sortedcollection.st,v 1.3 2012-03-07 14:40:03-08 - - $"

Object subclass: Name [
   |first last|
   first [^ first]
   last [^ last]
   Name class >> new [self shouldNotImplement]

   Name class >> new: last first: first [
      |result|
      result := super new.
      result setFirst: first setLast: last.
      ^ result.
   ]

   setFirst: myFirst setLast: myLast [
      first := myFirst.
      last := myLast.
   ]

   <= other [
      last = other last
         ifTrue: [^ first <= other first]
         ifFalse: [^ last <= other last].
   ]

   printOn: aStream [
      ^ aStream << last << ', ' << first.
   ]
]

sortcol := SortedCollection new.
sortcol add: (Name new: 'Doe' first: 'John').
sortcol add: (Name new: 'Roe' first: 'Mary').
sortcol add: (Name new: 'Smith' first: 'Joe').
sortcol add: (Name new: 'Smith' first: 'Jane').

nl := Character nl.
sortcol do: [:item| stdout << item << nl.].

"TEST: sortedcollection.st"

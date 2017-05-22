#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: divide.st,v 1.3 2014-10-22 15:44:14-07 - - $"

"Division operations."
"/    exact division, delivers a fraction"
"//   integer division, truncate to negative infinity"
"\\   integer modulus, corresponds to //"
"quo: integer division, truncate toward zero"
"rem: integer remainder, corresponds to quo:"

nl := Character nl.

rat := -7 /    3. stdout << 'rat = ' << rat << nl. rat inspect.
div := -7 //   3. stdout << 'div = ' << div << nl. div inspect.
mod := -7 \\   3. stdout << 'mod = ' << mod << nl. mod inspect.
quo := -7 quo: 3. stdout << 'quo = ' << quo << nl. quo inspect.
rem := -7 rem: 3. stdout << 'rem = ' << rem << nl. rem inspect.

"TEST: divide.st"

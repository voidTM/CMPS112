#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: ordinals.scm,v 1.2 2014-10-31 17:35:08-07 - - $

(map (lambda (fn)
             (display (fn '(1 2 3 4 5 6 7 8 9 10)))
             (newline))
     (list first second third fourth fifth
           sixth seventh eighth ninth tenth))


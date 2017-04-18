#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: divmod.scm,v 1.2 2014-10-31 17:35:08-07 - - $

(define (div n1 n2) (floor (/ n1 n2)))
(define mod modulo)
(define quo quotient)
(define rem remainder)

(define (printdivmod n1 n2)
        (begin (printf "(div ~s ~s) = ~s~n" n1 n2 (div n1 n2))
               (printf "(mod ~s ~s) = ~s~n" n1 n2 (mod n1 n2))
               (printf "(quo ~s ~s) = ~s~n" n1 n2 (quo n1 n2))
               (printf "(rem ~s ~s) = ~s~n" n1 n2 (rem n1 n2))
))

(define (printalldivmod n1 n2)
        (begin (printdivmod n1 n2)
               (printdivmod n1 (- n2))
               (printdivmod (- n1) n2)
               (printdivmod (- n1) (- n2))
))

(printalldivmod 13 4)

;; OUTPUT:
;; (div 13 4) = 3
;; (mod 13 4) = 1
;; (quo 13 4) = 3
;; (rem 13 4) = 1
;; (div 13 -4) = -4
;; (mod 13 -4) = -3
;; (quo 13 -4) = -3
;; (rem 13 -4) = 1
;; (div -13 4) = -4
;; (mod -13 4) = 3
;; (quo -13 4) = -3
;; (rem -13 4) = -1
;; (div -13 -4) = 3
;; (mod -13 -4) = -1
;; (quo -13 -4) = 3
;; (rem -13 -4) = -1
;; 

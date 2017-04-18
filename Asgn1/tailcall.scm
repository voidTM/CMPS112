#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: tailcall.scm,v 1.2 2014-10-31 17:35:08-07 - - $

;;
;; Blow the stack by infinite recursion.  In a non-tail recursive
;; language, this would use up the process's stack quota and then
;; crash.  In Scheme, since this function is tail recursive, it
;; acts just like an infinite loop in other languages -- it does
;; not blow up the stack but does use up as much CPU as it can.
;;

(define modulus 1000000)

{define (tailcall count)
        (when (= (remainder count modulus) 0)
              [printf "count = ~a~n" count])
        [tailcall (+ 1 count)]}

(tailcall 0)


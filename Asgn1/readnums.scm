#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: readnums.scm,v 1.2 2014-10-31 17:35:08-07 - - $

;;
;; Read numbers from stdin, stopping at end of file.
;;

{define (readnumber)
        (let ((object (read)))
             (cond [(eof-object? object) object]
                   [(number? object) (+ object 0.0)]
                   [else (begin (printf "invalid number: ~a~n" object)
                                (readnumber))] )) }

{define (testinput)
        (let ((number (readnumber)))
             (if (eof-object? number)
                 (printf "*EOF*~n")
                 (begin (printf "number = ~a~n" number)
                        (testinput)))) }

(testinput)


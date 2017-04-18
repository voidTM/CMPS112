;; $Id: varargs.scm,v 1.2 2009-02-12 19:41:43-08 - - $
;;
;; load with (load "varargs.scm")
;;
;; example defining a function with a variable number of params
;;

(define (writeln . list) (map write list) (newline))

(define (foo fst snd . rem )
        (writeln "foo = " foo)
        (writeln "fst = " fst)
        (writeln "snd = " snd)
        (writeln "rem = " rem))


;; $Id: lazylist.scm,v 1.1 2009-02-12 19:38:42-08 - - $

;;
;; This program shows factorial, the ``hello world'' of functional
;; programming.  It also shows lazy evaluation.  Note that the
;; ``positiveintegers'' described below contain a lazy list of all
;; positive integers in the range $2^29-1$.  Bigloo Scheme uses
;; 30-bit signed integers.
;;

(define (fac n)
    (if (< n 1) 1
        (* n (fac (- n 1)))
))

(define (printfac n)
    (printf "~s! = ~s~n" n (fac n))
)

(define (.. first last)
    (if (> first last) '()
        (delay (cons first (.. (+ first 1) last)))
))

(define positiveintegers (.. 1 +inf.0))

(define (take n lazylist)
    (if (<= n 0) '()
        (let ((forcedlist (force lazylist)))
             (cons (car forcedlist)
                   (take (- n 1) (cdr forcedlist)))
)))

(define (lazytake n lazylist)
    (if (<= n 0) '()
        (let ((forcedlist (force lazylist)))
             (delay (cons (car forcedlist)
                          (lazytake (- n 1) (cdr forcedlist))))
)))

(define (lazymap fn lazylist)
    (if (null? lazylist) '()
        (let ((forcedlist (force lazylist)))
             (cons (fn (car forcedlist))
                   (lazymap fn (cdr forcedlist)))
)))

(lazymap printfac (lazytake 32 positiveintegers))


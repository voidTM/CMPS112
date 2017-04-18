#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: hashexample.scm,v 1.2 2014-10-31 17:35:08-07 - - $
;;
;; Another hash table example, showing insertion of variables,
;; vectors, and functions, and checking for lookup.
;; Note the script above uses -qr instead of -qC.
;;

;;
;; A little utility function to make printing easier.
;; Mz Scheme does have a printf function, but we'll stick to
;; standard Scheme here.
;;
(define (show label it)
    (display label)
    (display " = ")
    (display it)
    (newline)
)

;;
;; Create a hash table and put in some functions and variables.
;;
(define ht (make-hash))
(for-each
    (lambda (item) (hash-set! ht (car item) (cadr item)))
    `((var 34)
      (+ ,(lambda (x y) (+ x y)))
      (- ,(lambda (x y) (- x y)))
      (* ,*)
      (vec ,(make-vector 10 0.0)))
)

;;
;; Print the hash table.
;;
(hash-for-each ht (lambda (key value) (show key value)))
(newline)

;;
;; show the value of a simple variable.
;; the last argument #f causes hash-ref to return it
;; rather than crashing the program on failure to find.
;;
(show "var" (hash-ref ht 'var #f))

;;
;; Set a vector element, print it, and the whole vector.
;;
(vector-set! (hash-ref ht 'vec #f) 5 3.1415926535)
(show "vec[5]" (vector-ref (hash-ref ht 'vec) 5))
(show "vec" (hash-ref ht 'vec #f))

;;
;; A couple more examples.
;;
(show "(+ 3 4)" (apply (hash-ref ht '+ #f) '(3 4)))
(show "not found" (hash-ref ht 'foo #f))

;;
;; The function evalexpr outlines how to evaluate a list
;; recursively.
;;
(define (evalexpr expr)
   (cond ((number? expr) expr)
         ((symbol? expr) (hash-ref ht expr #f))
         ((pair? expr)   (apply (hash-ref ht (car expr))
                                (map evalexpr (cdr expr))))
         (else #f))
)

;;
;; Now print out the value of several expressions.
;;
(for-each
    (lambda (expr) (show expr (evalexpr expr)))
    '( (* var 7)
       (- 3 4)
       (+ (* var 7) (- 3 4))
))

;;
;; Just to verify that we got all the way.
;;
(display "DONE.") (newline)

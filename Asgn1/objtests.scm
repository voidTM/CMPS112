#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: objtests.scm,v 1.4 2014-10-31 17:35:08-07 - - $

(define e  (exp 1))
(define pi (atan 0 -1))
(define i  (sqrt -1))

(define the-list
     `(

   (arg0     ,(find-system-path 'run-file))
   (e^ipi    ,(expt e (* i pi)))
   (hello    world)
   (integer  3)
   (list     (car cadr caddr))
   (log      ,log)
   (null     ())
   (number   3.141592653589793238462643383279502884197169399)
   (pair     (1 . 2))
   (sqrt-1   ,(sqrt -1))
   (string   "string")
   (vector   ,(make-vector 10 0))

))

(define tests `(

   (,boolean?   boolean?)
   (,char?      char?)
   (,complex?   complex?)
   (,integer?   integer?)
   (,list?      list?)
   (,number?    number?)
   (,pair?      pair?)
   (,path?      path?)
   (,procedure? procedure?)
   (,rational?  rational?)
   (,real?      real?)
   (,string?    string?)
   (,symbol?    symbol?)
   (,vector?    vector?)

))

(define (print-prop element)
        (let ((key (car element))
              (val (cadr element)))
             (printf "~s => ~s:~n" key val)
             (for-each (lambda (pair)
                       (when ((car pair) val)
                       (printf "   ~s~n" (cadr pair))))
                       tests)
             (newline)))

(for-each print-prop the-list)


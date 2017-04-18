#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: mergesort.scm,v 1.2 2014-10-31 17:35:08-07 - - $

(define (foldl fn unit lis)
        (if (null? lis) unit
            (foldl fn (fn unit (car lis)) (cdr lis))))

(define (foldr fn unit lis)
        (if (null? lis) unit
            (fn (car lis) (foldr fn unit (cdr lis)))))

(define (grep ok? lis)
        (define (test hd tl) (if (ok? hd) (cons hd tl) tl))
        (foldr test '() lis))

(define (mergesort <? lis)
        (define (flipflop tf) (lambda (_) (set! tf (not tf)) tf))
        (define (merge lis1 lis2)
                (cond ((null? lis1) lis2)
                      ((null? lis2) lis1)
                      ((<? (car lis1) (car lis2))
                            (cons (car lis1) (merge (cdr lis1) lis2)))
                      (else (cons (car lis2) (merge lis1 (cdr lis2))))))
        (define (msort lis)
                (if (or (null? lis) (null? (cdr lis))) lis
                    (merge (msort (grep (flipflop #t) lis))
                           (msort (grep (flipflop #f) lis)))))
        (msort lis))


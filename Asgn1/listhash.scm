#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: listhash.scm,v 1.3 2015-10-09 14:16:37-07 - - $

;;
;; NAME
;;    listhash - put some entries in a list into a hash table
;;

(define *hash* (make-hash))

(define *list*
    '(  (label (foo bar))
        (      (line 2))
        (sec   (sec line))
        (      (line 4))
        (last  (label))
        (      (end))))

(define (show label item)
        (newline)
        (display label) (display ":") (newline)
        (display item) (newline))

(define (put-in-hash list)
        (when (not (null? list))
              (let ((first (caar list)))
                   (when (symbol? first)
                         (hash-set! *hash* first list)))
              (put-in-hash (cdr list))))

(show "whole list" *list*)

(put-in-hash *list*)

(hash-for-each *hash*
    (lambda (key value) (show key value)))

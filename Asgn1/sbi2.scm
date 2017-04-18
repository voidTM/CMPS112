#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/racket/bin/mzscheme -qr
;; $Id: sbi.scm,v 1.3 2016-09-23 18:23:20-07 - - $
;;
;; NAME
;;    sbi.scm - silly basic interpreter
;;
;; SYNOPSIS
;;    sbi.scm filename.sbir
;;
;; DESCRIPTION
;;    The file mentioned in argv[1] is read and assumed to be an SBIR
;;    program, which is the executed.  Currently it is only printed.
;; To Do
;;    Store lines into a list
;;    Read from list
;;    Jump table?
;;

;; OPERATIONS
(define *stderr* (current-error-port))

(define *run-file*
    (let-values
        (((dirpath basepath root?)
            (split-path (find-system-path 'run-file))))
        (path->string basepath))
)

;; prints list then dies?
(define (die list)
    (for-each (lambda (item) (display item *stderr*)) list)
    (newline *stderr*)
    (exit 1)
)

(define (usage-exit)
    (die `("Usage: " ,*run-file* " filename"))
)

(define (readlist-from-inputfile filename)
    (let ((inputfile (open-input-file filename)))
         (if (not (input-port? inputfile))
             (die `(,*run-file* ": " ,filename ": open failed"))
             (let ((program (read inputfile)))
                  (close-input-port inputfile)
                      program
             )
         )
    )
)

(define (run-expr expr)
  (printf "~s~n" expr)
)

;; SBIR Statements

;;(define (dim-statement args))

;;(define ())

(define (read-list lst)
  (printf "~s~n" (length lst))
  ;;(printf "~s~n" lst)
  (when (and (< 0 (length lst)) (list? (cdr lst)))
    (run-expr (car lst))
    (read-list (cdr lst))
  )
)

(define (add-labels program)
    (map
        (lambda (line)
            (when
                (or (= 3 (length line))
                    (and (= 2 (length line))
                        (not (list? (cadr line)))
                    )
                )
                (printf "~n~s is label ~s ~n" (cadr line) (car line))
                (when (< 1 (length (cdr line)))
                  (printf "~n~s" (caaddr line))
                )
                ;;(hash-set! *label-table* (cadr line) (car line))

            )
        )
            program
    )
)


(define (write-program-by-line filename program)
    (printf "==================================================~n")
    (printf "~a: ~s~n" *run-file* filename)
    (printf "==================================================~n")
    ;; each line is a list?
    (map (lambda (line)
      ;;(printf "~s~n" line)
      (printf "~s~n" (length line))
      (cond
         ;;presume that there needs two expressions to be evaluated
        ((= 3 (length line))
          (printf "~s~n" (caaddr line)))

        ;; presume only 1 expression to be evaluated
        ;;((= 2 (length line))
          ;;(printf "~s~n" (caadr line))
        ;;)
        ((and (= 2 (length line)) (list? (cadr line)))
          (printf "~s~n" (caadr line)))
      )
      ;;(read-list (cdr line))
    )program)
)

;; take in a program list and then interpret line by line


(define (main arglist)
    (if (or (null? arglist) (not (null? (cdr arglist))))
        (usage-exit)
        (let* ((sbprogfile (car arglist))
               (program (readlist-from-inputfile sbprogfile)))
              ;;(add-labels program)
              (write-program-by-line sbprogfile program)

        )
    )
)

(main (vector->list (current-command-line-arguments)))

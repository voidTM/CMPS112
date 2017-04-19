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


;; GLOBAL VARIABLES

  ;; program index counter
(define program-counter 0)
(define program-list '())

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

;; PROGRAM MOVEMENT

(define (run-function func-name argv)
  ((hash-ref *function-table* func-name) argv)
)

;; given a line find the inner most statement
(define (get-statement line)
  (cond
    ;;presume that there needs two expressions to be evaluated
    ((= 3 (length line))
      (run-function (caaddr line) (cdaddr line))

      ;;(printf "~s~n" (caaddr line))
    )

      ;; presume only 1 expression to be evaluated
    ((and (= 2 (length line)) (list? (cadr line)))
      (run-function (caadr line) (cdadr line))
      ;;(printf "~s~n" (caadr line))
      ;;(printf "~s~n" (cdadr line))
    )
  )
)

(define (shorten-line line)
  ;;(printf "~s~n" line)

  (if (< 2 (length line))
     (shorten-line (cdr line))
     line
  )
)


;; Goes through the file looking for labels
;; then addes them to the label tabel
(define (add-labels program)
    (map
        (lambda (line)
          (when
            (or (= 3 (length line))
                (and (= 2 (length line))
                  (not (list? (cadr line)))
                )
            )
            ;;(printf "~n~s is label ~s ~n" (cadr line) (car line))
            (hash-set! *label-table* (cadr line) (- (car line) 1 ))
            ;;(printf "~n~s" (hash->list *label-table*))
          )
        )
    program
    )
)


;; tail end recursive implimentation or indexing through?
;; status recursion working normally
;; add goto part
(define (interpret-program program line-count)
  ;;(printf "~s~n" line-count)
  (set! program-counter line-count)
  (when (< 0 (length program))
    (get-statement (car program))
    ;; Check for changes to the program counter by jumps/gotos

    (when (not (= program-counter line-count))
      (set! program (move-to-line program-list program-counter 1))
      (set! line-count program-counter)
      ;;(map (lambda (line) (printf "~s~n" line)) program)
      ;;(newline)
    )

    ;; increment current program counter and index to next line
    (interpret-program (cdr program) (+ line-count 1))
  )
)


;; SBIR Statements

;; prints every of a line preceeding the print
(define (ft_print expr)
  (map (lambda (x)
    (display (eval-args x))
  ) expr)
   (newline)
)

;; creates an array
(define (ft_dim expr)
  (set! expr (car expr))
  (printf "~s~n" (car expr))
  (variable-put! (car expr)  
    (make-vector 
      (inexact->exact (eval-args(cadr expr)))
    )
  )
  ;;(printf "~s~n" (hash-ref *variable-table* (car expr)))
)

;; inserts the a variable into the variable table with its value
(define (ft_let expr)
  ;(function-put! (car expr) (eval-hash (cadr expr)))
  (printf "~s~n" (car expr))
  (printf "~s~n" (cadr expr))

  (variable-put! (car expr) (cdr expr))
)


(define (ft_input2 expr count)
  (if(null? expr)
    count
    (let ((input (read)))
      (if (eof-object? input)
        -1
        (begin
          (variable-put! (car expr) input)
          (set! count (+ 1 count))
          (ft_input2 (cdr expr) count)))))
  )

(define (ft_input expr)
  (variable-put! 'inputcount 0)
  (if(null? (car expr))
    (variable-put! 'inputcount -1)
    (begin
    (variable-put! 'inputcount (ft_input2 expr 0))))
  )

;; resets the program counter to the label value
;; for now presume that there is only 1 arguement for goto

(define (ft_goto label)
  ;;(printf "~s~n" (hash->list *label-table*))
  (set! program-counter (hash-ref *label-table* (car label)))
)

;; Presumes the format if (var expr expr) label
(define (ft_if argv)
  (when (eval-args(car argv))
    ;; if true pass label to goto
    (printf "~s~n" (car argv))
    (printf "~s~n" (cadr argv))
    (ft_goto (cdr argv))
  )
)

;; HELPER FUNCTIONS

(define (eval-args argv)
  (cond
    ((number? argv) (+ 0.0 argv))
    
    ((pair? argv)
      (eval-args (car argv))
      (eval-args (cdr argv))
    )
    (else argv)
  )
)

;; move to line as specified from the initial line of 0
(define (move-to-line program linenr currLine)
  ;;(printf "~s~n" linenr)
  ;;(printf "~s~n" currLine)
  (if ( < currLine linenr)
    (move-to-line (cdr program) linenr (+ currLine 1))
    program
  )
)

;; TABLES

;; function-tablegit
;; associated with the 6 functions in statements
(define *function-table* (make-hash))
(define (function-put! key value)
    (hash-set! *function-table* key value))
(for-each
  (lambda (pair) (function-put! (car pair) (cadr pair)))
  `(
    ;; functions
    (dim , ft_dim)
    (let , ft_let)
    (print , ft_print)
    (input , ft_input)
    (goto , ft_goto)
    (if , ft_if)
  )
)

;; variable-table
;; functions are included
(define *variable-table* (make-hash))
(define (variable-put! key value)
    (hash-set! *variable-table* key value))
(for-each
  (lambda (pair) (variable-put! (car pair) (cadr pair)))
  `(
    ;; variables
    (log10_2 0.301029995663981195213738894724493026768189881)
    (sqrt_2  1.414213562373095048801688724209698078569671875)
    (e       2.718281828459045235360287471352662497757247093)
    (pi      3.141592653589793238462643383279502884197169399)
    (div     ,(lambda (x y) (floor (/ x y))))
    (log10   ,(lambda (x) (/ (log x) (log 10.0))))
    (mod     ,(lambda (x y) (- x (* (div x y) y))))
    (quot    ,(lambda (x y) (truncate (/ x y))))
    (rem     ,(lambda (x y) (- x (* (quot x y) y))))
    (<>      ,(lambda (x y) (not(= x y))))
    (+       ,+)
    (-       ,-)
    (*       ,*)
    (/       ,/)
    (<=      ,<=)
    (>=      ,>=)
    (=       ,=)
    (<       ,<)
    (>       ,>)
    (abs     ,abs)
    (sin     ,sin)
    (cos     ,cos)
    (tan     ,tan)
    (acos    ,acos)
    (asin    ,asin)
    (atan    ,atan)
    (trunc   ,truncate)
    (>       ,>)
    (>       ,>)
    (^       ,expt)
    (ceil    ,ceiling)
    (round   ,round)
    (exp     ,exp)
    (floor   ,floor)
    (log     ,log)
    (sqrt    ,sqrt)
  )
)

;; label-table
;; holds addresses of each line, one level up from statements
(define *label-table* (make-hash))
(define (label-put! key value)
    (hash-set! *label-table* key value))
(for-each
  (lambda (pair)
    ;;First element in list is key other elements are value
    (label-put! (car pair) (cadr pair)))
  `(
    ))

(define (hash-labels program)
   (map (lambda (line)
          (when (not (null? line))
            (when (or (= 3 (length line))
                      (and (= 2 (length line))
                           (not (list? (cadr line)))))
                (hash-set! *label-table* (cadr line)  (- (car line) 1 ))
                ))) program)
)


(define (main arglist)
    (if (or (null? arglist) (not (null? (cdr arglist))))
        (usage-exit)
        (let* ((sbprogfile (car arglist))
               (program (readlist-from-inputfile sbprogfile)))
              (set! program-list program)
              (add-labels program)
              ;;(hash-labels program)
              (interpret-program program 0)

        )
    )
)

(main (vector->list (current-command-line-arguments)))

(define *stderr* (current-error-port))

;;(define *unread-stream* (open-output-string))

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
                         program))))

;; Assumes that given a print statement print each element 1 by 1
(define (print-line line)
    ;; prints each statement within the line
    (map (lambda (statement) (print statement)) line))
    (define (read-program program)
      (map (lambda (line))

      )
;; let() creates locally defined variables
(define (write-program-by-line filename program)
    ;; takes a list, and a procedure, and applies the procedure
    ;; to every element of the list, creating a new list with the results
    ;; program is the list
    (for-each (lambda(line)
      (print line)
      ;;(let unread(open-input-string line))
      ;;(let head(read unread))
      ;;(when (= (head) "print")
        ;;(print-line unread))
       program)))

;; take in a program list and then interpret line by line

(define (main arglist)
    (if (or (null? arglist) (not (null? (cdr arglist))))
        (usage-exit)
        (let* ((sbprogfile (car arglist))
               (program (readlist-from-inputfile sbprogfile)))
               ;; interpret and operate on program here

              (write-program-by-line sbprogfile program))))



(main (vector->list (current-command-line-arguments)))







(define (write-program-by-line filename program)
    (printf "==================================================~n")
    (printf "~a: ~s~n" *run-file* filename)
    (printf "==================================================~n")
    (printf "(~n")
    ;; takes a list, and a procedure, and applies the procedure
    ;; to every element of the list, creating a new list with the results
    ;; program is the list
    (for-each
    ;; line is not necessarily a string?
      (lambda (line)
        ;;(let (l (list (string-split line)))
        (printf "~n~s is label ~s ~n" (cadr line) (car line))

      )
      program)
    (printf ")~n"))

    (define (insert-labels program)
        (map
            (lambda (line)
                (when
                    (or (= 3 (length line))
                        (and (= 2 (length line))
                            (not (list? (cadr line)))
                        )
                    )
                    (printf "~n~s is label ~s ~n" (cadr line) (car line))
                    (hash-set! *label-table* (cadr line) (car line))

                )
            )
                program
        )
    )

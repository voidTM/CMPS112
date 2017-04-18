
     ((lambda (x)
       (list x (list (quote quote) x)))
      (quote
         (lambda (x)
           (list x (list (quote quote) x)))))

;; $Id: quine.scm,v 1.1 2009-02-12 19:38:42-08 - - $

#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["procedure.rkt" (proc?)]
 )

(provide (all-defined-out))

(define (report-expval-extractor-error type val)
  (eopl:error 'expval-extractors "Looking for a ~s, found ~s" type val)
  )

(define-datatype expval expval?
  (num-val (num number?))
  (bool-val (bool boolean?))
  (proc-val (proc1 proc?))
  ; new stuff
  (pair-val (val1 expval?) (val2 expval?))
  )

(define (expval->num val)
  (cases expval val
    (num-val (num) num)
    (else (report-expval-extractor-error 'num val))
    )
  )

(define (expval->bool val)
  (cases expval val
    (bool-val (bool) bool)
    (else (report-expval-extractor-error 'bool val))
    )
  )

(define (expval->proc val)
  (cases expval val
    (proc-val (proc1) proc1)
    (else (report-expval-extractor-error 'proc val))
    )
  )

; new stuff
(define (expval->pair val)
  (cases expval val
    (pair-val (val1 val2) (cons val1 val2))
    (else (report-expval-extractor-error 'pair val))
    )
  )

(define sloppy->expval
  (lambda (sloppy-val)
    (cond
      ((number? sloppy-val) (num-val sloppy-val))
      ((boolean? sloppy-val) (bool-val sloppy-val))
      ; new stuff
      ((pair? sloppy-val) (pair-val (car sloppy-val) (cdr sloppy-val)))
      (else
       (eopl:error 'sloppy->expval
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))

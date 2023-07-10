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
  (null-val)
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

(define (is-uninitialized? val)
  (cases expval val
    (null-val () #t)
    (else #f)
    )
  )

(define sloppy->expval
  (lambda (sloppy-val)
    (cond
      ((number? sloppy-val) (num-val sloppy-val))
      ((boolean? sloppy-val) (bool-val sloppy-val))
      ((eq? 'null sloppy-val) (null-val))
      (else
       (eopl:error 'sloppy->expval
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))

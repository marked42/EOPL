#lang eopl

(require racket/lazy-require "basic.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (environment?)]
 ["procedure.rkt" (proc?)]
 ["store.rkt" (reference?)]
 ["pair1.rkt" (mut-pair?)]
 )

(provide (all-defined-out))

(define-datatype expval expval?
  (num-val
   (num number?)
   )
  (bool-val
   (bool boolean?)
   )
  (proc-val (proc1 proc?))
  (ref-val (ref reference?))
  (pair-val (pair mut-pair?))
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

(define (expval->ref val)
  (cases expval val
    (ref-val (ref) ref)
    (else (eopl:error "expect a ref, get ~s" val))
    )
  )

(define (expval->pair-val val)
  (cases expval val
    (pair-val (p) p)
    (else (eopl:error "expect a pair, get ~s" val))
    )
  )

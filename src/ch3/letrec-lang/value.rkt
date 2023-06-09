#lang eopl

(require racket/lazy-require "basic.rkt" "expression.rkt")
(lazy-require
  ["environment.rkt" (environment?)]
  ["procedure.rkt" (proc?)]
)

(provide (all-defined-out))

(define-datatype expval expval?
  (num-val
   (num number?)
   )
  (bool-val
   (bool boolean?)
   )
  (null-val)
  (cell-val
   (first expval?)
   (second expval?)
   )
  (proc-val (proc1 proc?))
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

(define (cell-val->first val)
  (cases expval val
    (cell-val (first second) first)
    (null-val () (null-val))
    (else "error")
    )
  )

(define (cell-val->second val)
  (cases expval val
    (cell-val (first second) second)
    (null-val () (null-val))
    (else "error")
    )
  )

(define (null-val? val)
  (cases expval val
    (null-val () #t)
    (else #f)
    )
  )

(define (cell-val? val)
  (cases expval val
    (cell-val (first second) #t)
    (else #f)
    )
  )

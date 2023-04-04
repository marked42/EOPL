#lang eopl

(require racket/lazy-require)
(require "basic.rkt")
(require "expression.rkt")
(lazy-require ["environment.rkt" (environment?)])

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
  (proc-val (proc! proc?))
  )

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  (trace-procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
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

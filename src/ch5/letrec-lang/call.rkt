#lang eopl

(require
  racket/lazy-require
  ; use program and expression datatype
  "../shared/expression.rkt"
  )

(lazy-require
 ["interpreter.rkt" (value-of/k)]
 ["continuation.rkt" (apply-cont)]
 ["../shared/store.rkt" (deref)]
 ["../shared/environment.rkt" (apply-env)]
 )

(provide (all-defined-out))

(define (eval-operand-call-by-value exp1 saved-env saved-cont)
  ; just get the value of exp1
  (value-of/k exp1 saved-env saved-cont)
  )

#lang eopl

(require racket/lazy-require)
(lazy-require
 ["interpreter.rkt" (value-of/k)]
 ["../shared/call.rkt" (make-eval-operand-call-by-value)]
 )

(provide (all-defined-out))

(define (eval-operand-call-by-value exp1 saved-env saved-cont)
  ; just get the value of exp1
  (make-eval-operand-call-by-value value-of/k exp1 saved-env saved-cont)
  )

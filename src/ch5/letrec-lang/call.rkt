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

(define (eval-call-by-ref-operand exp1 saved-env saved-cont)
  (cases expression exp1
    (var-exp (var)
             (let ((val (deref (apply-env saved-env var))))
               (apply-cont saved-cont val)
               )
             )
    (else
     (value-of/k exp1 saved-env saved-cont)
     )
    )
  )

(define (eval-call-by-value-operand exp1 saved-env saved-cont)
  (value-of/k exp1 saved-env saved-cont)
  )

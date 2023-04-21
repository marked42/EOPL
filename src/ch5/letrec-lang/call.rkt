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
  (cases expression exp1
    (var-exp (var)
             ; call by value
             ; deref so that value instead of ref is passed as procedure parameters
             (let ((val (deref (apply-env saved-env var))))
               (apply-cont saved-cont val)
               )
             )
    (else
     (value-of/k exp1 saved-env saved-cont)
     )
    )
  )

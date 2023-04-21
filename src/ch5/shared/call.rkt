#lang eopl

(require
  racket/lazy-require
  ; use program and expression datatype
  "expression.rkt"
  )

(lazy-require
 ["environment.rkt" (apply-env)]
 )

(provide (all-defined-out))

(define (make-eval-operand-call-by-value value-of/k exp1 saved-env saved-cont)
  ; just get the value of exp1
  (value-of/k exp1 saved-env saved-cont)
  )

(define (make-eval-operand-call-by-ref value-of/k apply-cont exp1 saved-env saved-cont)
  (cases expression exp1
    (var-exp (var)
             ; call by ref
             (let ((ref (apply-env saved-env var)))
               (apply-cont saved-cont ref )
               )
             )
    (else
     (value-of/k exp1 saved-env saved-cont)
     )
    )
  )

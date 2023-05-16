#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (tfexp?)]
 ["interpreter.rkt" (value-of/k)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body tfexp?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of/k body (extend-mul-env vars args saved-env) cont)
               )
    )
  )

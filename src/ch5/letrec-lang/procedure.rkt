#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of/k)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args saved-cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of/k body (extend-mul-env vars args saved-env) saved-cont)
               )
    )
  )

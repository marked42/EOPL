#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of-exp body (extend-mul-env vars args saved-env))
               )
    )
  )

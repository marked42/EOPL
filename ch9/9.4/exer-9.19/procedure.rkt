#lang eopl

(require racket/lazy-require "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)]
 ["store.rkt" (newref)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (body expression?)
   (saved-env nameless-environment?)
   )
  )

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (body saved-env)
               (value-of-exp body (extend-nameless-env (map newref args) saved-env))
               )
    )
  )

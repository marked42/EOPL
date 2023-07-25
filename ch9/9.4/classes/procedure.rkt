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
   (vars (list-of symbol?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 arg)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of-exp body (extend-env* vars (list (newref arg)) saved-env))
               )
    )
  )

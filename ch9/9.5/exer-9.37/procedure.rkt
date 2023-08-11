#lang eopl

(require racket/lazy-require "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)]
 ["store.rkt" (newref)]
 ["checker/type.rkt" (type?)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of symbol?))
   (types (list-of type?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (vars types body saved-env)
               (value-of-exp body (extend-env* vars (map newref args) types saved-env))
               )
    )
  )

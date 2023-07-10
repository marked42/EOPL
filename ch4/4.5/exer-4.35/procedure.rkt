#lang eopl

(require racket/lazy-require "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)]
 ["store.rkt" (newref)]
 ["value.rkt" (expval->ref)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (var symbol?)
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 arg)
  (cases proc proc1
    (procedure (var body saved-env)
               ; new stuff
               (value-of-exp body (extend-env var (expval->ref arg) saved-env))
               )
    )
  )

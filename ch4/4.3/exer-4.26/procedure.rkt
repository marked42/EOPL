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

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (vars body saved-env)
               ; new stuff
               (value-of-exp body (extend-env* vars (map (lambda (arg) (newref arg)) args) saved-env))
               )
    )
  )

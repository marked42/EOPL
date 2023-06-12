#lang eopl

(require racket/lazy-require "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (body expression?)
   (saved-env nameless-environment?)
   )
  )

(define (apply-procedure proc1 arg)
  (cases proc proc1
    (procedure (body saved-env)
               (value-of-exp body (extend-nameless-env arg saved-env))
               )
    )
  )

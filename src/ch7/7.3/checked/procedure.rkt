#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (var identifier?)
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 arg)
  (cases proc proc1
    (procedure (var body saved-env)
               (value-of-exp body (extend-env (list var) (list arg) saved-env))
               )
    )
  )

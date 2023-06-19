#lang eopl

(require racket/lazy-require "environment.rkt" "answer.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (var symbol?)
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 arg store)
  (cases proc proc1
    (procedure (var body saved-env)
               (value-of-exp body (extend-env var arg saved-env) store)
               )
    )
  )

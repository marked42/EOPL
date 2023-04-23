#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of/k)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (var identifier?)
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure/k proc1 arg saved-cont)
  (cases proc proc1
    (procedure (var body saved-env)
               (value-of/k body (extend-env var arg saved-env) saved-cont)
               )
    )
  )

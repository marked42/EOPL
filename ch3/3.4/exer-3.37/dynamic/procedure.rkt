#lang eopl

(require racket/lazy-require)
(lazy-require
 ["expression.rkt" (expression?)]
 ["environment.rkt" (extend-env*)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (var symbol?)
   (body expression?)
   )
  )

(define (apply-procedure proc1 arg env)
  (cases proc proc1
    (procedure (var body)
               (value-of-exp body (extend-env* (list var) (list arg) env))
               )
    )
  )

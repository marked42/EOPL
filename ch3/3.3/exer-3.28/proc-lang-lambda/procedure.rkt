#lang eopl

(provide (all-defined-out))

(require racket/lazy-require "environment.rkt")
(lazy-require
 ["interpreter.rkt" (value-of-exp)])

(define (proc? val) (procedure? val))

(define (procedure var body)
  (lambda (val env)
    (value-of-exp body (extend-env* (list var) (list val) env))
    )
  )

(define (apply-procedure proc arg env)
  (proc arg env)
  )

#lang eopl

(require racket/lazy-require)
(lazy-require
 ["basic.rkt" (identifier?)]
 ["environment.rkt" (environment?)]
 ["expression.rkt" (expression?)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

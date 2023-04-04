#lang eopl

(provide (all-defined-out))
(require "basic.rkt")
(require "expression.rkt")
(require "environment.rkt")

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  (trace-procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

#lang eopl

(provide (all-defined-out))
(require "basic.rkt")
(require "expression.rkt")
(require "environment.rkt")

(define-datatype proc proc?
  (procedure
   (body expression?)
   (saved-env environment?)
   )
  )

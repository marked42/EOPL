#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-duplicate-module
  (list
   (list "
module m1
  interface [u : int]
  body [u = 44]
module m1
  interface [v : int]
  body [v = -(from m1 take u,11)] %= 33
from m1 take u
      " 11 "multiple modules with let* scoping rule")

   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-simple-modules
            test-cases-duplicate-module
            )
           )

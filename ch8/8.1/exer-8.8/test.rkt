#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define simple-modules-example-8.4
  (list
   (list "
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
from m1 take u
      " 44 "Example 8.4 allow definition order to be different with interface order")
   )
  )

(test-lang run sloppy->expval
    (append
        test-cases-simple-modules-common
        simple-modules-example-8.4
        )
)

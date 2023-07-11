#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-add-declared-names-to-module-env-only
  (list
   (list "
module m1
  interface [
    a : int
    b : int
    c : int
  ]
  body [
    a = 33
    x = -(a,1) %= 32
    b = -(a,x) %= 1
    c = -(x,b) %= 31
  ]
let a = 10
      in from m1 take x
      " 'error "Exmaple 8.1 internal x in m1 should not be visible")
   )
  )


(test-lang run sloppy->expval
           (append
            test-cases-simple-modules
            test-cases-add-declared-names-to-module-env-only
            )
           )

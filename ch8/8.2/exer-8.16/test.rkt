#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-proc-with-multiple-arguments
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
let diff = proc (x: int, y: int) -(x,y)
    m1a = from m1 take a
    m1b = from m1 take b
      in (diff -(m1a, m1b) 10)
      " 22 "Exmaple 8.1 single module")
   )
  )

(define test-cases-letrec-exp-with-multiple-declarartions
  (list
   (list "
letrec int double(x: int) = if zero?(x) then 0 else -((double -(x,1)), -2)
       int triple(x: int) = if zero?(x) then 0 else -((triple -(x,1)), -3)
    in (triple (double 6))
" 36 "letrec-exp with multiple declarations")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-simple-modules
            test-cases-opaque-types
            test-cases-let-exp-with-multiple-declarations
            test-cases-proc-with-multiple-arguments
            test-cases-letrec-exp-with-multiple-declarartions
            )
           )

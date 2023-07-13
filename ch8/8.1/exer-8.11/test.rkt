#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-type-inference
  (list
   (list "
module m
    interface [f : (int -> bool)]
    body [f = proc (x : ?) x]
1
   " 'error "invalid proc type")

   (list "
module m
    interface [f : (int -> int)]
    body [f = proc (x : ?) x]
1
   " 1 "valid proc type")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-simple-modules
            test-cases-type-inference
            )
           )

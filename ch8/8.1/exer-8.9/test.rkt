#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-depends-on
  (list
   (list "
module m1
  interface [a : int b : int]
  body [a = 1 b = 2]
module m2
  interface [a : int b : int]
  body [a = 3 b = 4]
module m3
  interface [a : int b : int]
  body [a = 5 b = 6]
module m4
  interface [a : int b : int]
  body [a = 7 b = 8]
module m5
  interface [a : int b : int]
  body
    m1, m3
    [
        a = -(from m3 take a, from m1 take a) %= 4
        b = -(from m3 take b, from m1 take b) %= 4
    ]
-(from m5 take a, from m5 take b) %= 0
      " 0 "depends-on")
   )
  )

(test-lang run sloppy->expval test-cases-depends-on)

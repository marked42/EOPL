#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-let-with-mutliple-declarations
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
    m1a = from m1 take a
    m1b = from m1 take b
      in -(-(m1a, m1b), a)
      " 22 "Exmaple 8.1 single module")
   )
  )

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
let diff = proc (x, y) -(x,y)
    m1a = from m1 take a
    m1b = from m1 take b
      in (diff -(m1a, m1b) 10)
      " 22 "Exmaple 8.1 single module")
   )
  )
(test-lang run sloppy->expval
           (
            append
            test-cases-let-with-mutliple-declarations
            test-cases-simple-modules)
           )

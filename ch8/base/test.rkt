#lang eopl

(require racket racket/list rackunit)

(provide (all-defined-out))

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

(define test-cases-letrec-in-module-body
  (list
   (list "
module even-odd
  interface [
    even : (int -> bool)
    odd  : (int -> bool)
  ]
  body
    letrec bool local-odd  (x : int) = if zero?(x) then #f else (local-even -(x,1))
           bool local-even (x : int) = if zero?(x) then #t else (local-odd  -(x,1))
      in [
        even = local-even
        odd  = local-odd
      ]
(from even-odd take odd 13)
      " #t "letrec in module body")
   )
  )

(define test-cases-let-in-module-body
  (list
   (list "
module m1
  interface [
    left: int
    right: int
  ]
  body
    let a = 1
        b = 2
      in [
        left = a
        right = b
      ]
-(from m1 take left, from m1 take right)
      " -1 "let in module body")
   )
  )

(define test-cases-local-module
  (list
   (list "
module m1
  interface [u : int v : int]
  body
    module m2
      interface [v : int]
      body [v = 33]
    [
      u = 44
      v = -(from m2 take v, 1) %= 32
    ]
-(from m1 take u, from m1 take v) %= 12
      " 12 "local module definition")
   )
  )

(define test-cases-interface-order
  (list
   (list "
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
from m1 take u
      " 44 "allow definition order to be different with interface order")
   )
  )

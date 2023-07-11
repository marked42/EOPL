#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-module-syntax-dot
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
      in -(-(m1.a, m1.b), a)
      " 22 "Exmaple 8.1 single module")

   (list "
module m1
  interface [u : int]
  body [u = 44]
module m2
  interface [v : int]
  body [v = -(m1.u,11)] %= 33
-(m1.u, m2.v) %= 11
      " 11 "multiple modules with let* scoping rule")

   (list "
module m1
  interface [u : bool]
  body [u = 33]
m1.u
      " 'error "Example 8.2 module m1 u declared as bool, implemented as int")

   (list "
module m1
  interface [
    u : int
    v : int
  ]
  body [u = 33]
44
      " 'error "Example 8.3 module m1 missing implementation for v: int ")

   (list "
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
m1.u
      " 'error "Example 8.4 module m1 declaration order and implementation order mismatch")

   (list "
module m1
  interface [u : int]
  body [u = 44]
module m2
  interface [v : int]
  body [v = -(m1.u,11)] %= 33
-(m1.u, m2.v)
      " 11 "Example 8.5 module definitions uses let* scoping rule, correct order: m1, m2")

   (list "
module m2
  interface [v : int]
  body [v = -(m1.u,11)]
module m1
  interface [u : int]
  body [u = 44]
-(m1.u, m2.v)
      " 'error "Example 8.5 module definitions uses let* scoping rule, incorrect order: m2, m1")
   )
  )

(test-lang run sloppy->expval test-cases-module-syntax-dot)

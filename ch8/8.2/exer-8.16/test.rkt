#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-opaque-types
  (list
   (list "
module m1
    interface [
        opaque t
        z: t
        s: (t -> t)
        is-z? : (t -> bool)
    ]
    body [
        type t = int
        z = 33
        s = proc (x : t) -(x,-1)
        is-z? = proc (x : t) zero?(-(x,z))
    ]
proc (x : from m1 take t)
    (from m1 take is-z? -(x,0))
      " 'error' "Example 8.7 throw error when not respecting opaque type")

   (list "
module m1
    interface [
        opaque t
        z: t
        s: (t -> t)
        is-z? : (t -> bool)
    ]
    body [
        type t = int
        z = 33
        s = proc (x : t) -(x,-1)
        is-z? = proc (x : t) zero?(-(x,z))
    ]
(proc (x : from m1 take t)
    (from m1 take is-z? x)
   from m1 take z)
      " #t ' "Example 8.7 pass type checking when using exported z of same opaque type")

   (list "
module colors
    interface [
        opaque color
        red : color
        green : color
        is-red? : (color -> bool)
    ]
    body [
        type color = int
        red = 0
        green = 1
        is-red? = proc (c : color) zero?(c)
    ]
(from colors take is-red? from colors take red)
      " #t ' "Example 8.8 is-red returns true for red")

   (list "
module colors
    interface [
        opaque color
        red : color
        green : color
        is-red? : (color -> bool)
    ]
    body [
        type color = int
        red = 0
        green = 1
        is-red? = proc (c : color) zero?(c)
    ]
(from colors take is-red? from colors take green)
      " #f ' "Example 8.8 is-red returns false for green")

   (list "
module ints1
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5) is-zero = proc (x : t) zero?(x)
    ]
let z = from ints1 take zero
    in let s = from ints1 take succ
        in (s (s z))
      " 10 ' "Example 8.9 represent integer k with 5*k")

   (list "
module ints2
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,3)
        pred = proc(x : t) -(x,-3) is-zero = proc (x : t) zero?(x)
    ]
let z = from ints2 take zero
    in let s = from ints2 take succ
        in (s (s z))
      " -6 "Example 8.10 represent integer k with -3*k")

   (list "
module ints1
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5) is-zero = proc (x : t) zero?(x)
    ]
let z = from ints1 take zero
    in let s = from ints1 take succ
        in let p = from ints1 take pred
            in let z? = from ints1 take is-zero
                in letrec int to-int (x : from ints1 take t) = if (z? x)
                                                               then 0
                                                               else -((to-int (p x)), -1)
                    in (to-int (s (s z)))
      " 2 ' "Example 8.11 to-int implemented using inst1")

   (list "
module ints2
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,3)
        pred = proc(x : t) -(x,-3) is-zero = proc (x : t) zero?(x)
    ]
let z = from ints2 take zero
    in let s = from ints2 take succ
        in let p = from ints2 take pred
            in let z? = from ints2 take is-zero
                in letrec int to-int (x : from ints2 take t) = if (z? x)
                                                               then 0
                                                               else -((to-int (p x)), -1)
                    in (to-int (s (s z)))
      " 2 ' "Example 8.12 to-int implemented using inst2")

   (list "
module mybool
    interface [
        opaque t
        true : t
        false : t
        and : (t -> (t -> t))
        not : (t -> t)
        to-bool : (t -> bool)
    ]
    body [
        type t = int
        true = 0
        false = 13
        and = proc (x : t) proc (y : t) if zero?(x) then y else false
        not = proc (x : t) if zero?(x) then false else true
        to-bool = proc (x : t) zero?(x)
    ]
let true = from mybool take true
    in let false = from mybool take false
        in let and = from mybool take and
            in ((and true) false)
      " 13 ' "Example 8.13 my-bool false represented as 13")

   (list "
module ints
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 3
        step = 5
        succ = proc(x : t) -(x,-(0, step))
        pred = proc(x : t) -(x,step)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
let z = from ints take zero
    in let s = from ints take succ
        in (s (s z))
      " 13 ' "Exercise 8.13 represent integer k as 5*k+3")

   (list "
module tables
    interface [
        opaque table
        empty: table
        add-to-table: (int -> (int -> (table -> table)))
        lookup-in-table: (int -> (table -> int))
    ]
    body [
        type table = (int -> int)
        empty = proc (x: int) 0
        add-to-table = proc (x: int) proc (y: int) proc (t: table)
                            proc (target: int)
                                if zero?(-(target, x))
                                then y
                                else (t target)
        lookup-in-table = proc (x: int) proc (t: table) (t x)
    ]
let empty = from tables take empty
    in let add-binding = from tables take add-to-table
        in let lookup = from tables take lookup-in-table
            in let table1 = (((add-binding 3) 300)
                             (((add-binding 4) 400)
                              (((add-binding 3) 600) empty)))
                in -(((lookup 4) table1), ((lookup 3) table1)) %= 100
      " 100 ' "Exercise 8.15 tables module")
   )
)

(test-lang run sloppy->expval
    (append
        ; test-cases-simple-modules
        test-cases-opaque-types
        test-cases-let-exp-with-multiple-declarations
    )
)

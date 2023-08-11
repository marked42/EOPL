#lang eopl

(require racket racket/list rackunit)

(provide (all-defined-out))

(define (test-lang run sloppy->expval test-cases)
  (let ([equal-answer? (lambda (ans correct-ans msg) (check-equal? ans (sloppy->expval correct-ans) msg))])
    (map (lambda (test-case)
           (let ([source (first test-case)] [expected (second test-case)] [msg (third test-case)])
             (if (equal? expected 'error)
                 (check-exn exn:fail? (lambda () (run source)))
                 (equal-answer? (run source) expected msg)
                 )
             )
           ) test-cases)
    )
  )

(define test-cases-const-exp
  (list
   (list "1" 1 "const-exp")
   )
  )

(define test-cases-diff-exp
  (list
   (list "-(1, 2)" -1 "diff-exp")
   )
  )

(define test-cases-sum-exp
  (list
   (list "+(1, 2)" 3 "sum-exp")
   )
  )

(define test-cases-zero?-exp
  (list
   (list "zero?(0)" #t "zero?-exp")
   (list "zero?(1)" #f "zero?-exp")
   )
  )

(define test-cases-if-exp
  (list
   (list "if zero? (0) then 2 else 3" 2 "if exp")
   (list "if zero? (1) then 2 else 3" 3 "if exp")
   )
  )

(define test-cases-var-exp
  (list
   (list "i" 1 "built in var i is 1")
   (list "v" 5 "built in var i is 5")
   (list "x" 10 "built in var i is 10")
   )
  )

(define test-cases-let-exp
  (list
   (list "let a = 1 in -(a, x)" -9 "let exp")
   )
  )

(define test-cases-let-exp-with-multiple-declarations
  (list
   (list "let a = 1 b = 2 in -(a, b)" -1 "let exp with multiple declarations")
   (list "
let x = 30
      in let x = -(x,1)
             y = -(x,2)
         in -(x,y)
   " 1 "let exp with multiple declarations")
   )
  )

(define test-cases-let-lang
  (append
   test-cases-const-exp
   test-cases-diff-exp
   test-cases-zero?-exp
   test-cases-var-exp
   test-cases-if-exp
   test-cases-let-exp
   )
  )

(define test-cases-print-exp
  (list
   (list "print(0)" 1 "print-exp")
   (list "print(zero?(0))" 1 "print-exp")
   )
  )

(define test-cases-let-lang-with-multiple-declarations
  (append
   test-cases-const-exp
   test-cases-diff-exp
   test-cases-zero?-exp
   test-cases-var-exp
   test-cases-if-exp
   test-cases-let-exp-with-multiple-declarations
   )
  )

(define test-cases-let*-exp
  (list
   (list "
let x = 30
  in let* x = -(x,1) y = -(x,2)
    in -(x,y)
    " 2 "let*-exp")
   )
  )

(define test-cases-unpack-exp
  (list
   (list "
let u = 7 in
  unpack x y = cons(u,cons(3,emptylist))
    in -(x,y)
    " 4 "unpack-exp")
   )
  )

(define test-cases-let*-lang
  (append
   test-cases-let-lang
   test-cases-let*-exp
   )
  )

(define test-cases-proc-exp
  (list
   (list "let f = proc (x) -(x,11) in (f (f 77))" 55 "proc-exp")
   (list "(proc (f) (f (f 77)) proc (x) -(x,11))" 55 "proc-exp")
   )
  )

(define test-cases-curried-sum
  (list
   (list "let f = proc (x) proc (y) -(x, -(0, y)) in ((f 3) 4)" 7 "curried-sum")
   )
  )

(define test-cases-letproc-exp
  (list
   (list "letproc f (x) -(x,11) in (f (f 77))" 55 "letproc-exp")
   )
  )

(define test-cases-proc-lang
  (append
   test-cases-let-lang
   test-cases-proc-exp
   )
  )

(define test-cases-proc-exp-with-multiple-arguments
  (list
   (list "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)" 7 "proc-exp with multiple arguments")
   )
  )

(define test-cases-proc-lang-with-multiple-arguments
  (append
   test-cases-let-lang
   test-cases-proc-exp
   test-cases-proc-exp-with-multiple-arguments
   )
  )

(define test-cases-dynamic-scoping
  (list
   (list "
let a = 3
  in let p = proc (x) -(x,a)
         a = 5
    in -(a,(p 2))
" 8 "dynamic scoping"
  )
   (list "
let a = 3
    in let p = proc (z) a
        in let f = proc (x) (p 0)
          in let a = 5
            in (f 2)
" 5 "exer 3.29 dynamic scoping is hard to understand"
  )
   (list "
let a = 3
    in let p = proc (z) a
        in let f = proc (a) (p 0)
          in let a = 5
            in (f 2)
" 2 "exer 3.29 dynamic scoping is hard to understand"
  )
   )
  )

(define test-cases-letrec-exp
  (list
   (list "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 6)
" 12 "letrec-exp")
   )
  )

(define test-cases-letrec-exp-with-multiple-arguments
  (list
   (list "
letrec mul(x, y)
  = if zero?(x) then 0 else -((mul -(x,1) y), -(0, y))
    in (mul 6 2)
" 12 "letrec-exp")
   )
  )

(define test-cases-letrec-lang
  (append
   test-cases-proc-lang
   test-cases-letrec-exp
   )
  )

(define test-cases-minus-exp
  (list
   (list "minus(-(minus(5), 9))" 14 "minus-exp")
   )
  )

(define test-cases-arithmetic
  (list
   (list "+(1, 2)" 3 "sum exp")
   (list "*(2, 3)" 6 "mul-exp")
   (list "/(4, 2)" 2 "div-exp")
   )
  )

(define test-cases-comparison
  (list
   (list "equal?(4, 2)" #f "equal?-exp")
   (list "equal?(2, 2)" #t "equal?-exp")
   (list "greater?(3, 2)" #t "greater?-exp")
   (list "greater?(3, 3)" #f "greater?-exp")
   (list "greater?(3, 4)" #f "greater?-exp")
   (list "less?(3, 2)" #f "less?-exp")
   (list "less?(3, 3)" #f "less?-exp")
   (list "less?(3, 4)" #t "less?-exp")
   )
  )

(define test-cases-list-exp
  (list
   (list  "list(1, 2, 3)" (list 1 2 3) "list-exp")
   (list  "let x = 4 in list(x, -(x, 1), -(x, 3))" (list 4 3 1) "list-exp")
   )
  )

(define test-cases-list-v1
  (list
   (list "emptylist" '() "emptylist-exp")
   (list "cons(1, 2)" (cons 1 2) "cons-exp")

   (list "null?(emptylist)" #t "null?-exp")
   (list "null?(cons(1, 2))" #f "null?-exp")

   (list "car(cons(1, 2))" 1 "car-exp")
   (list "car(emptylist)" '() "car-exp")

   (list "cdr(cons(1, 2))" 2 "cdr-exp")
   (list "cdr(emptylist)" '() "cdr-exp")
   )
  )

(define test-cases-list-v2
  (append
   test-cases-list-v1
   test-cases-list-exp
   )
  )

(define test-cases-cond-exp
  (list
   (list "cond zero?(1) ==> 1 zero?(0) ==> 0 end" 0 "cond-exp")
   (list "cond zero?(0) ==> 0 zero?(1) ==> 1 end" 0 "cond-exp")
   )
  )

(define test-cases-letrec-exp-with-multiple-declarartions
  (list
   (list "
letrec double(x) = if zero?(x) then 0 else -((double -(x,1)), -2)
       triple(x) = if zero?(x) then 0 else -((triple -(x,1)), -3)
    in (triple (double 6))
" 36 "letrec-exp with multiple declarations")
   )
  )

(define test-cases-letrec-lang-with-multiple-declarations
  (append
   test-cases-letrec-lang
   test-cases-letrec-exp-with-multiple-declarartions
   )
  )

(define test-cases-ref-exp
  (list
   (list "
    let a = newref(43)
      in let b = newref(42)
        in -(deref(a), deref(b))
    " 1 "deref retrieves value of a ref")

   (list "
    let a = newref(42)
      in let b = setref(a, 43)
        in deref(a)
    " 43 "setref! updates value of a ref")

   (list "
    let a = newref(42)
      in setref(a, 43)
    " 23 "setref returns an arbitrary number 2")
   )
  )

(define test-cases-explicit-refs
  (append
   test-cases-letrec-lang
   test-cases-ref-exp
   )
  )

(define test-cases-begin-exp
  (list
   (list "begin 1; 2; 3 end" 3 "begin-exp")
   )
  )

(define test-cases-implicit-refs
  (list
   (list "
let x = 0
  in letrec even(dummy)
            = if zero?(x)
              then 1
              else begin
                set x = -(x,1);
                (odd 888)
              end
            odd(dummy)
            = if zero?(x)
              then 0
              else begin
                set x = -(x,1);
                (even 888)
              end
        in begin set x = 13; (odd -888) end
" 1 "implicit refs")
   )
  )

(define test-cases-letmutable-exp
  (list
   (list "
letmutable x = 0
  in letrec even(dummy)
            = if zero?(x)
              then 1
              else begin
                set x = -(x,1);
                (odd 888)
              end
            odd(dummy)
            = if zero?(x)
              then 0
              else begin
                set x = -(x,1);
                (even 888)
              end
        in begin set x = 13; (odd -888) end
" 1 "letmutable declares mutable variables")
   )
  )

(define test-cases-implicit-refs-lang
  (append
   test-cases-letrec-lang-with-multiple-declarations
   test-cases-begin-exp
   test-cases-implicit-refs
   )
  )

(define test-cases-setdynamic-exp
  (list
   (list "
let x = 11
      in let p = proc (y) -(y,x)
in -(setdynamic x = 17 during (p 22), (p 13))
" 3 "setdynamic expression"
  )
   )
  )

(define test-cases-mutable-pair-exp
  (list
   (list "
let glo = pair(11,22)
  in let f = proc (loc)
              let d1 = setright(loc, left(loc))
                 in let d2 = setleft(glo, 99)
                    in -(left(loc),right(loc))
      in (f glo)
      " 88 "mutable-pair")
   )
  )

(define test-cases-mutable-pair-lang
  (append
   test-cases-implicit-refs-lang
   test-cases-mutable-pair-exp
   )
  )

(define test-cases-array-exp
  (list
   (list "
let a = newarray(2,-99)
  in let p = proc (x)
          let v = arrayref(x,1)
            in arrayset(x,1,-(v,-1))
      in begin
        arrayset(a,1,0);
        (p a);
        (p a);
        arrayref(a,1)
      end
      " 2 "array")
   )
  )

(define test-cases-array-check-index-exp
  (list
   (list "
let a = newarray(2,-99)
  in arrayref(a, -1)
      " 'error "array ref index out of bounds")
   (list "
let a = newarray(2,-99)
  in arrayref(a, 0)
      " -99 "array ref index within range")
   (list "
let a = newarray(2,-99)
  in arrayref(a, 1)
      " -99 "array ref index within range")
   (list "
let a = newarray(2,-99)
  in arrayref(a, 2)
      " 'error "array ref index out of bounds")
   (list "
let a = newarray(2,-99)
  in arrayref(a, 3)
      " 'error "array ref index out of bounds")

   (list "
let a = newarray(2,-99)
  in arrayset(a, -1, 42)
      " 'error "array set index out of bounds")
   (list "
let a = newarray(2,-99)
  in arrayset(a, 0, 42)
      " 42 "array set index within range")
   (list "
let a = newarray(2,-99)
  in arrayset(a, 1, 42)
      " 42 "array set index within range")
   (list "
let a = newarray(2,-99)
  in arrayset(a, 2, 42)
      " 'error "array set index out of bounds")
   (list "
let a = newarray(2,-99)
  in arrayset(a, 3, 42)
      " 'error "array set index out of bounds")
   )
  )

(define test-cases-array-length-exp
  (list
   (list "
let a = newarray(2,-99)
  in arraylength(a)
      " 2 "array")
   )
  )

(define test-cases-call-by-reference
  (list
   (list "
let p = proc (x) set x = 4
      in let a = 3
         in begin (p a); a end
    " 4 "call-by-reference")
   (list "
  let f = proc (x) set x = 44 in let g = proc (y) (f y)
        in let z = 55
          in begin (g z); z end
   " 44 "call-by-reference")

   (list "
let swap = proc (x) proc (y) let temp = x
                  in begin
                      set x = y;
                      set y = temp
                     end
      in let a = 33
         in let b = 44
            in begin
                ((swap a) b);
                -(a,b)
            end
  " 11 "swap two values under call by reference")
   )
  )

(define test-cases-call-by-reference-lang
  (append
   test-cases-implicit-refs-lang
   test-cases-call-by-reference
   )
  )

(define test-cases-call-by-name
  (list
   (list "
letrec infinite-loop (x) = (infinite-loop -(x,-1))
  in let f = proc (z) 11
    in (f (infinite-loop 0))
" 11 "call-by-name allows infinite loop by lazy evaluation"
  )
   )
  )

(define test-cases-call-by-name-lang
  (append
   test-cases-call-by-reference-lang
   test-cases-call-by-name
   )
  )

(define test-cases-checked
  (list
   (list "let f = proc (x : int) -(x,11) in (f (f 77))" 55 "proc-exp")
   (list "(proc (f : (int -> int)) (f (f 77)) proc (x : int) -(x,11))" 55 "proc-exp")
   (list "
    letrec int double(x: int)
      = if zero?(x) then 0 else -((double -(x,1)), -2)
        in (double 6)
    " 12 "letrec-exp")
   )
  )

(define test-cases-checked-lang
  (append
   test-cases-let-lang
   test-cases-checked
   )
  )

(define tests-cases-checked-letrec-with-multiple-arguments
  (list
   (list "
    letrec int double(x: int, y: int)
      = if zero?(x) then 0 else -((double -(x,1) -(y,1)), -4)
        in (double 6 6)
    " 24 "letrec-exp")
   )
  )

(define tests-cases-checked-letrec-with-multiple-declarations
  (list
   (list "
letrec int double(x: int) = if zero?(x) then 0 else -((double -(x,1)), -2)
       int triple(x: int) = if zero?(x) then 0 else -((triple -(x,1)), -3)
    in (triple (double 6))
    " 36 "letrec-exp")
   )
  )

(define test-cases-exer-7.5
  (append
   test-cases-checked
   test-cases-let-lang-with-multiple-declarations
   tests-cases-checked-letrec-with-multiple-arguments
   tests-cases-checked-letrec-with-multiple-declarations
   )
  )

(define test-cases-checked-assignment
  (list
   (list "
let x = 0
  in begin set x = 1; x end
" 1 "assignment")
   )
  )

(define test-cases-exer-7.6
  (append
   test-cases-checked-lang
   test-cases-begin-exp
   test-cases-checked-assignment
   )
  )

(define test-cases-exer-7.7
  (append
   test-cases-checked-lang
   (list
    (list "if 1 then 11 else 12" 11 "not checking condition of if-exp as bool")
    )
   )
  )

(define test-cases-exer-7.8
  (append
   test-cases-checked-lang
   (list
    (list "let a = newpair(1, 2) in unpair b c = a in -(b, c)" -1 "pair exp")
    )
   )
  )

(define test-cases-exer-7.9-list
  (list
   (list "let a = emptylist_ int in null?(a)" #t "null? returns true for emptylist")
   (list "let a = 1 in null?(a)" 'error "throws error when null? receives non list type value")

   (list "cons(1, emptylist_ int)" '(1) "cons builds a int list from an int and another empty int list type")
   (list "cons(1, emptylist_ bool)" 'error "cons throws error when element type and list element type is not same")

   (list "null?(cons(1, emptylist_ int))" #f "null? returns false for non empty list")

   (list "list(1, 2)" '(1 2) "list builds a list of int")
   (list "list()" 'error "list throws error when containing no elements")
   (list "list(1, zero(1))" 'error "throws error element type are not same")
   )
  )

(define test-cases-exer-7.9
  (append
   test-cases-checked-lang
   test-cases-exer-7.9-list
   )
  )

(define test-cases-checked-mutable-pair-exp
  (list
   (list "
let glo = pair(11,22)
  in let f = proc (loc: pairof int * int)
              let d1 = setright(loc, left(loc))
                 in let d2 = setleft(glo, 99)
                    in -(left(loc),right(loc))
      in (f glo)
      " 88 "mutable-pair")
   )
  )

(define test-cases-simple-modules-common
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
      in -(-(from m1 take a, from m1 take b), a)
      " 22 "Exmaple 8.1 single module")

   (list "
module m1
  interface [u : int]
  body [u = 44]
module m2
  interface [v : int]
  body [v = -(from m1 take u,11)] %= 33
-(from m1 take u, from m2 take v) %= 11
      " 11 "multiple modules with let* scoping rule")

   (list "
module m1
  interface [u : bool]
  body [u = 33]
from m1 take u
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
  interface [u : int]
  body [u = 44]
module m2
  interface [v : int]
  body [v = -(from m1 take u,11)] %= 33
-(from m1 take u, from m2 take v)
      " 11 "Example 8.5 module definitions uses let* scoping rule, correct order: m1, m2")

   (list "
module m2
  interface [v : int]
  body [v = -(from m1 take u,11)]
module m1
  interface [u : int]
  body [u = 44]
-(from m1 take u, from m2 take v)
      " 'error "Example 8.5 module definitions uses let* scoping rule, incorrect order: m2, m1")
   )
  )

(define test-cases-example-8.4
  (list
   (list "
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
from m1 take u
      " 'error "Example 8.4 module m1 declaration order and implementation order mismatch")
   )
  )

(define test-cases-simple-modules
  (append
   test-cases-simple-modules-common
   test-cases-example-8.4
   )
  )

(define test-cases-interface-ignore-order
  (list
   (list "
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
from m1 take u
      " 44 "allow definition order to be different with interface order")
   )
  )

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
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
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
        pred = proc(x : t) -(x,-3)
        is-zero = proc (x : t) zero?(x)
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
      " 2 ' "Example 8.11 to-int implemented using ints1")

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
      " 2 ' "Example 8.12 to-int implemented using ints2")

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

(define test-cases-to-int-maker
  (list
   (list "
module ints1
    interface [
        opaque t
        zero : t
        pred : (t -> t)
        succ : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        pred = proc(x : t) -(x,5)
        succ = proc(x : t) -(x,-5)
        is-zero = proc (x : t) zero?(x)
    ]
module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
let one = (from ints1 take succ from ints1 take zero)
in (from ints1-to-int take to-int one)
            " 1 "to-int-maker example 1 create ints1-to-in from ints1 using to-int-maker")

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
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]
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
        pred = proc(x : t) -(x,-3)
        is-zero = proc (x : t) zero?(x)
    ]

module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
module ints2-to-int
    interface [
        to-int: (from ints2 take t -> int)
    ]
    body
        (to-int-maker ints2)
let one1 = (from ints1 take succ from ints1 take zero)
in let one2 = (from ints2 take succ from ints2 take zero)
in -((from ints1-to-int take to-int one1),(from ints2-to-int take to-int one2))
               " 0 "to-int-maker example 2: diff of same value from two modules is 0")
   )
  )

(define test-cases-from-int-maker
  (list
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
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]
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
        pred = proc(x : t) -(x,-3)
        is-zero = proc (x : t) zero?(x)
    ]

module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
module ints2-to-int
    interface [
        to-int: (from ints2 take t -> int)
    ]
    body
        (to-int-maker ints2)

module from-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            from-int: (int -> from ints take t)
        ])
    body
      module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            from-int = let zero = from ints take zero
                        in let succ = from ints take succ
                            in letrec from ints take t from-int (x: int) = if zero?(x) then zero else (succ (from-int -(x,1)))
                                in from-int
        ]
module ints1-from-int
    interface [
        from-int: (int -> from ints1 take t)
    ]
    body
        (from-int-maker ints1)
module ints2-from-int
    interface [
        from-int: (int -> from ints2 take t)
    ]
    body
        (from-int-maker ints2)
let three1 = (from ints1-from-int take from-int 3)
in let three2 = (from ints2-from-int take from-int 3)
in -((from ints1-to-int take to-int three1), (from ints2-to-int take to-int three2))
               " 0 "exer 8.19")
   )
  )

(define test-cases-sum-prod-maker
  (list
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
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]
module sum-prod-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            plus: (from ints take t -> (from ints take t -> from ints take t))
            times: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus
            times = letrec (from ints take t -> from ints take t) times (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then from ints take zero
                            else ((plus ((times (from ints take pred x)) y)) y)
                        in times
        ]
module ints1-sum-prod
    interface [
        plus: (from ints1 take t -> (from ints1 take t -> from ints1 take t))
        times: (from ints1 take t -> (from ints1 take t -> from ints1 take t))
    ]
    body
        (sum-prod-maker ints1)
let zero = from ints1 take zero
in let one = (from ints1 take succ zero)
in let two = (from ints1 take succ one)
in ((from ints1-sum-prod take plus one) two)
" 15 "exer 8.19 ints represents k in 5*k, so (plus one two) is three 15")

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
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]
module sum-prod-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            plus: (from ints take t -> (from ints take t -> from ints take t))
            times: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus
            times = letrec (from ints take t -> from ints take t) times (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then from ints take zero
                            else ((plus ((times (from ints take pred x)) y)) y)
                        in times
        ]
module ints1-sum-prod
    interface [
        plus: (from ints1 take t -> (from ints1 take t -> from ints1 take t))
        times: (from ints1 take t -> (from ints1 take t -> from ints1 take t))
    ]
    body
        (sum-prod-maker ints1)
let zero = from ints1 take zero
in let one = (from ints1 take succ zero)
in let two = (from ints1 take succ one)
in ((from ints1-sum-prod take times two) two)
" 20 "exer 8.19 ints represents k in 5*k, so (times two two) is four 5 * 4 = 20")
   )
  )

(define test-cases-double-ints-maker
  (list
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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in let one = (from ints take succ zero)
in ((from ints-double take diff one) zero)
" 8 "double-ints-maker diff 1 - 0 is 1, 5*k + 3 = 8")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in let one = (from ints take succ zero)
in ((from ints-double take diff zero) one)
" -2 "double ints maker diff 1 - 0 is -1, 5*k + 3 = -2")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
            equal: (from ints take t -> (from ints take t -> bool))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
      equal: (from ints take t -> (from ints take t -> bool))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in let one = (from ints take succ zero)
in ((from ints-double take equal zero) one)
" #f "double-ints-maker (equal 1 0) = false ")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
            equal: (from ints take t -> (from ints take t -> bool))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
      equal: (from ints take t -> (from ints take t -> bool))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in ((from ints-double take equal zero) zero)
" #t "double-ints-maker (equal 0 0) = true")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
            equal: (from ints take t -> (from ints take t -> bool))
            average: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
      equal: (from ints take t -> (from ints take t -> bool))
      average: (from ints take t -> (from ints take t -> from ints take t))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in let one = (from ints take succ zero)
in let two = (from ints take succ one)
in ((from ints-double take average zero) two)
" 8 "double-ints-maker (average 0 2) = 1, 5*k + 3 = 8")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            diff: (from ints take t -> (from ints take t -> from ints take t))
            equal: (from ints take t -> (from ints take t -> bool))
            average: (from ints take t -> (from ints take t -> from ints take t))
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t

            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average
        ]
module ints-double
    interface [
      diff: (from ints take t -> (from ints take t -> from ints take t))
      equal: (from ints take t -> (from ints take t -> bool))
      average: (from ints take t -> (from ints take t -> from ints take t))
    ]
    body
      (double-ints-maker ints)
let zero = from ints take zero
in let one = (from ints take succ zero)
in let two = (from ints take succ one)
in ((from ints-double take average zero) two)
" 8 "double-ints-maker (average 0 2) = 1, 5*k + 3 = 8")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t
            zero = from ints take zero
        ]
module ints-double
    interface [
        opaque t
        zero: from ints take t
    ]
    body
      (double-ints-maker ints)
from ints-double take zero
" 3 "double-ints-maker double of zero is still zero")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            succ: (from ints take t -> from ints take t)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t
            zero = from ints take zero
            succ = proc (x: from ints take t) (from ints take succ (from ints take succ x))
        ]
module ints-double
    interface [
        opaque t
        zero: from ints take t
        succ: (from ints take t -> from ints take t)
    ]
    body
      (double-ints-maker ints)
(from ints-double take succ from ints-double take zero)
" 13 "double-ints-maker succ of zero is two, 5*k + 3 = 13")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            pred: (from ints take t -> from ints take t)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t
            zero = from ints take zero
            pred = proc (x: from ints take t) (from ints take pred (from ints take pred x))
        ]
module ints-double
    interface [
        opaque t
        zero: from ints take t
        pred: (from ints take t -> from ints take t)
    ]
    body
      (double-ints-maker ints)
(from ints-double take pred from ints-double take zero)
" -7 "double-ints-maker pred of zero is minus two, 5*k + 3 = -7")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            is-zero: (from ints take t -> bool)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t
            zero = from ints take zero

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average

            is-zero = proc (x: from ints take t) (from ints take is-zero ((average zero) x))
        ]
module ints-double
    interface [
        opaque t
        zero: from ints take t
        is-zero: (from ints take t -> bool)
    ]
    body
      (double-ints-maker ints)
(from ints-double take is-zero from ints-double take zero)
" #t "double-ints-maker (is-zero zero) is true")

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
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            succ: (from ints take t -> from ints take t)
            is-zero: (from ints take t -> bool)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            type t = from ints take t
            zero = from ints take zero

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average

            succ = proc (x: from ints take t) (from ints take succ (from ints take succ x))

            is-zero = proc (x: from ints take t) (from ints take is-zero ((average zero) x))
        ]
module ints-double
    interface [
        opaque t
        zero: from ints take t
        succ: (from ints take t -> from ints take t)
        is-zero: (from ints take t -> bool)
    ]
    body
      (double-ints-maker ints)
let one = (from ints-double take succ from ints-double take zero)
in (from ints-double take is-zero one)
" #f "double-ints-maker (is-zero one) is false")
   )
  )

(define test-cases-proc-module-multiple-arguments
  (list
   (list "
module ints1
    interface [ zero : int ]
    body [ zero = 3 ]
module ints2
    interface [ zero : int ]
    body [ zero = 6 ]

module zero-maker
    interface ((ints1: [ zero: int ], ints2: [ zero: int ]) => [ zero: int ])
    body
        module-proc (ints1: [ zero: int ], ints2: [ zero: int])
        [
          zero = -(from ints1 take zero, -(0, from ints2 take zero))
        ]
module compound-zero
    interface [ zero: int ]
    body (zero-maker ints1 ints2)
from compound-zero take zero
               " 9 "proc module with multiple arguments")
   )
  )

(define test-cases-declared-interface
  (list
   (list "
interface int-interface = [
  opaque t
  zero: t
  pred: (t -> t)
  succ: (t -> t)
  is-zero: (t -> bool)
]
module ints1
    interface [
        opaque t
        zero : t
        pred : (t -> t)
        succ : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        pred = proc(x : t) -(x,5)
        succ = proc(x : t) -(x,-5)
        is-zero = proc (x : t) zero?(x)
    ]
module to-int-maker
    interface
        ((ints: int-interface) => [ to-int: (from ints take t -> int) ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
let one = (from ints1 take succ from ints1 take zero)
in (from ints1-to-int take to-int one)
            " 1 "to-int-maker use declared interface in-interface as parameter type")
   )
  )

(define test-cases-application-module-body
  (list
   (list "
   module ints1
       interface [
           opaque t
           zero : t
           pred : (t -> t)
           succ : (t -> t)
           is-zero : (t -> bool)
       ]
       body [
           type t = int
           zero = 0
           pred = proc(x : t) -(x,5)
           succ = proc(x : t) -(x,-5)
           is-zero = proc (x : t) zero?(x)
       ]
   module ints1-to-int
       interface [
           to-int: (from ints1 take t -> int)
       ]
       body
           (module-proc (ints: [
               opaque t
               zero: t
               pred: (t -> t)
               succ: (t -> t)
               is-zero: (t -> bool)
           ])
           [
               to-int = let z? = from ints take is-zero
                           in let p = from ints take pred
                               in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                   in to-int
           ]
           ints1)
   let one = (from ints1 take succ from ints1 take zero)
   in (from ints1-to-int take to-int one)
               " 1 "application module-body supports non-identifier operator")

   (list "
module ints1-to-int
    interface [
        to-int: (int -> int)
    ]
    body
        (module-proc (ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
        [
        type t = int
        zero = 0
        pred = proc(x : t) -(x,5)
        succ = proc(x : t) -(x,-5)
        is-zero = proc (x : t) zero?(x)
    ])
1
            " 1 "application module-body supports non-identifier operand")
   )
  )

(define test-cases-proc-modules
  (append
   test-cases-to-int-maker
   test-cases-from-int-maker
   test-cases-sum-prod-maker
   test-cases-double-ints-maker
   )
  )

(define test-cases-classes
  (list
   (list "
class c1 extends object
  field i
  field j
  method initialize (x)
    begin
      set i = x;
      set j = -(0,x)
    end
  method countup (d)
    begin
      set i = +(i,d);
      set j = -(j,d)
    end
  method getstate ()
    list(i,j)
let t1 = 0
    t2 = 0
    o1 = new c1(3)
  in begin
    set t1 = send o1 getstate();
    send o1 countup(2);
    set t2 = send o1 getstate();
    list(t1,t2)
  end
            " (list (list 3 -3) (list 5 -5)) "Figure 9.1 A simple object-oriented program")

   (list "
class interior-node extends object
  field left
  field right
  method initialize (l, r)
    begin
      set left = l;
      set right = r
    end
  method sum ()
    +(send left sum(),send right sum())

class leaf-node extends object
  field value
  method initialize (v)
    set value = v
  method sum ()
    value
let o1 = new interior-node(
               new interior-node(
                new leaf-node(3),
                new leaf-node(4)),
               new leaf-node(5))
  in send o1 sum()
            " 12 "Figure 9.2 Object-oriented program for summing the leaves of a tree")

   (list "
class oddeven extends object
  method initialize ()
    1
  method even (n)
    if zero?(n)
    then 1
    else send self odd(-(n,1))
  method odd (n)
    if zero?(n)
    then 0 else
    send self even(-(n,1))

let o1 = new oddeven()
  in send o1 odd(13)
            " 1 "odd even")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method move (dx, dy)
    begin
      set x = +(x,dx);
      set y = +(y,dy)
    end
  method get-location ()
    list(x,y)

class colorpoint extends point
  field color
  method set-color (c)
    set color = c
  method get-color ()
    color
let p = new point(3,4)
    cp = new colorpoint(10,20)
  in begin
    send p move(3,4);
    send cp set-color(87);
    send cp move(10,20);
    list(send p get-location(),     %= (6, 8)
         send cp get-location(),    %= (20,40)
         send cp get-color())       %= 87
  end
            " (list (list 6 8) (list 20 40) 87) "Figure 9.3 Classic example of inheritance: colorpoint")

   (list "
class c1 extends object
  field x
  field y
  method initialize () 1
  method setx1 (v) set x = v
  method sety1 (v) set y = v
  method getx1 () x
  method gety1 () y

class c2 extends c1
  field y
  method sety2 (v) set y = v
  method getx2 () x
  method gety2 () y

let o2 = new c2()
  in begin
    send o2 setx1(101);
    send o2 sety1(102);
    send o2 sety2(999);
    list(send o2 getx1(),     % returns 101
         send o2 gety1(),     % returns 102
         send o2 getx2(),     % returns 101
         send o2 gety2())     % returns 999
  end
            " (list 101 102 101 999) "Figure 9.4 Example of field shadowing")

   (list "
class c1 extends object
  method initialize () 1
  method m1 () 11
  method m2 () send self m1()

class c2 extends c1
  method m1 () 22

let o1 = new c1()
    o2 = new c2()
  in list(send o1 m1(), send o2 m1(), send o2 m2())
            " (list 11 22 22) "send o2 m2() call m1 through dynamic dispatch in parent class")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end

  method move (dx, dy)
    begin
      set x = +(x,dx);
      set y = +(y,dy)
    end
  method get-location () list(x,y)

class colorpoint extends point
  field color
  method initialize (initx, inity, initcolor)
    begin
      set x = initx;
      set y = inity;
      set color = initcolor
    end

  method set-color (c)
    set color = c
  method get-color () color

let o1 = new colorpoint(3,4,172)
  in send o1 get-color()
            " 172 "Figure 9.5 Example demonstrating a need for super, use super initialize(intx, inty) in class colorpoint initialize method to remove duplicate code")

   (list "
class c1 extends object
  method initialize () 1
  method m1 () send self m2()
  method m2 () 13

class c2 extends c1
  method m1 () 22
  method m2 () 23
  method m3 () super m1()

class c3 extends c2
  method m1 () 32
  method m2 () 33

let o3 = new c3()
  in send o3 m3()
            " 33 "Figure 9.6 Example illustrating interaction of super call with self, send o3 m3() -> c2 m3 -> c1 m1 -> c3 m2")
   )
  )


(define test-cases-bogus-odd-even
  (list
   (list "
class oddeven extends object
  method initialize ()
    1
  method even (n)
    if zero?(n)
    then 1
    else send self odd(-(n,1))
  method odd (n)
    if zero?(n)
    then 0 else
    send self even(-(n,1))

class bogus-oddeven extends oddeven
    method even()
        0

let o1 = new bogus-oddeven()
  in send o1 odd(13)
            " 0 "sub class bogus-oddeven override even to return wrong answer")
   )
  )

(define test-cases-exer-9.1
  (list
   (list "
class queue extends object
    field lst

    method initialize()
        set lst = emptylist

    method empty?()
        null?(lst)

    method enqueue(item)
        set lst = cons(item, lst)

    method dequeue()
        letrec reverse_helper (q, reversed_q) = if send q empty?()
                                                then reversed_q
                                                else (reverse_helper cdr(q) cons(car(q), reversed_q))
            in (reverse_helper cdr((reverse_helper lst emptylist)) emptylist)

    method getlist()
        lst

let q = new queue()
    in send q getlist()
            " '() "Exer 9.1 1 empty queue")

   (list "
class queue extends object
    field lst

    method initialize()
        set lst = emptylist

    method empty?()
        null?(lst)

    method enqueue(item)
        set lst = cons(item, lst)

    method dequeue()
        letrec reverse_helper (q, reversed_q) = if send q empty?()
                                                then reversed_q
                                                else (reverse_helper cdr(q) cons(car(q), reversed_q))
            in (reverse_helper cdr((reverse_helper lst emptylist)) emptylist)

    method getlist()
        lst

let q = new queue()
    in begin
      send q enqueue(1);
      send q enqueue(2);
      send q enqueue(3);
      send q getlist()
    end
            " '(3 2 1) "Exer 9.1 1 enqueue")

   (list "
class queue extends object
    field lst

    method initialize()
        set lst = emptylist

    method empty?()
        null?(lst)

    method enqueue(item)
        set lst = cons(item, lst)

    method dequeue()
        letrec reverse_helper (q, reversed_q) = if null?(q)
                                                then reversed_q
                                                else (reverse_helper cdr(q) cons(car(q), reversed_q))
            in set lst = (reverse_helper cdr((reverse_helper lst emptylist)) emptylist)

    method getlist()
        lst

let q = new queue()
    in begin
      send q enqueue(1);
      send q enqueue(2);
      send q enqueue(3);
      send q dequeue();
      send q getlist()
    end
            " '(3 2) "Exer 9.1 1 dequeue")

   (list "
class queue extends object
    field counter
    field lst

    method initialize()
      begin
        set counter = 0;
        set lst = emptylist
      end

    method counter()
      counter

    method increment()
      set counter = +(counter, 1)

    method empty?()
        null?(lst)

    method enqueue(item)
      begin
        set lst = cons(item, lst);
        send self increment()
      end

    method dequeue()
        letrec reverse_helper (q, reversed_q) = if null?(q)
                                                then reversed_q
                                                else (reverse_helper cdr(q) cons(car(q), reversed_q))
            in begin
              set lst = (reverse_helper cdr((reverse_helper lst emptylist)) emptylist);
              send self increment()
            end

    method getlist()
        lst

let q = new queue()
    in begin
      send q enqueue(1);
      send q enqueue(2);
      send q enqueue(3);
      send q dequeue();
      send q getlist();
      send q counter()
    end
            " 4 "Exer 9.1 2 enqueue 3 times, dequeue 1 time, total 4 times")

   (list "
class counter extends object
  field count

  method initialize()
    set count = 0

  method value()
    count

  method increment()
    set count = +(count, 1)

class queue extends object
    field counter
    field lst

    method initialize(c)
      begin
        set counter = c;
        set lst = emptylist
      end

    method counter()
      send counter value()

    method empty?()
        null?(lst)

    method enqueue(item)
      begin
        set lst = cons(item, lst);
        send counter increment()
      end

    method dequeue()
        letrec reverse_helper (q, reversed_q) = if null?(q)
                                                then reversed_q
                                                else (reverse_helper cdr(q) cons(car(q), reversed_q))
            in begin
              set lst = (reverse_helper cdr((reverse_helper lst emptylist)) emptylist);
              send counter increment()
            end

    method getlist()
        lst

let c = new counter()
  in let q1 = new queue(c)
         q2 = new queue(c)
    in begin
      send q1 enqueue(1);
      send q1 enqueue(2);
      send q1 enqueue(3);
      send q1 dequeue();

      send q2 enqueue(1);
      send q2 enqueue(2);
      send q2 enqueue(3);
      send q2 dequeue();

      send c value()
    end
            " 8 "Exer 9.1 2 q1 has 4 operations, q2 has 4 operations, total 8 operations recorded in counter c")
   )
  )

(define test-cases-instanceof
  (list
   (list "
class c1 extends object
  method initialize() 1

class c2 extends object
  method initialize() 2

let o1 = new c1()
  in instanceof o1 c1
            " #t "object is instanceof of its class")

   (list "
class c1 extends object
  method initialize() 1

class c2 extends c1
  method initialize() 2

let o2 = new c2()
  in instanceof o2 c1
            " #t "object is instanceof of its ancestor class")

   (list "
class c1 extends object
  method initialize() 1

class c2 extends object
  method initialize() 2

let o2 = new c2()
  in instanceof o2 c1
            " #f "object is nont instanceof of unrelated class")
   )
  )

(define test-cases-fieldref-fieldset
  (list
   (list "
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o1 = new c1()
  in fieldref o1 x
            " 1 "fieldref x of o1 is 1")

   (list "
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o1 = new c1()
  in fieldref o1 y
            " 'error "throw error when referencing non exist field y of object")

   (list "
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o2 = new c2()
  in fieldref o2 x
            " 2 "fieldref x of o2 is 2, shadowing super class field")

   (list "
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o2 = new c2()
  in fieldref o2 y
            " 3 "fieldref y of o2 is 3")

   (list "
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o2 = new c2()
  in begin
    fieldset o2 x = 4;
    fieldset o2 y = 5;
    list(fieldref o2 x, fieldref o2 y)
  end
            " (list 4 5) "fieldset expression")
   )
  )

(define test-cases-super-field-ref-set
  (list
   (list "
class c1 extends object
  field x
  field y
  method initialize()
    begin
      set x = 1;
      set y = 2
    end


class c2 extends c1
  field x
  field y
  method initialize()
    begin
      super initialize();
      set x = 3;
      set y = 4
    end

let o = new c2()
  in list(superfieldref o x, superfieldref o y, fieldref o x, fieldref o y)
            " '(1 2 3 4) "superfieldref gets super field of a object")

   (list "
class c1 extends object
  field x
  field y
  method initialize()
    begin
      set x = 1;
      set y = 2
    end


class c2 extends c1
  field x
  field y
  method initialize()
    begin
      super initialize();
      set x = 3;
      set y = 4
    end

let o = new c2()
  in begin
    superfieldset o x = 5;
    superfieldset o y = 6;
    list(superfieldref o x, superfieldref o y)
  end
            " '(5 6) "superfieldset sets super field of a object")
   )
  )

(define test-cases-named-method-call
  (list
   (list "
class c1 extends object
  method initialize () 1
  method m1 () 11

class c2 extends c1
  method m1 () 22

let o1 = new c2()
  in list(send o1 m1(), named-send c2 o1 m1(), named-send c1 o1 m1())
            " '(22 22 11) "named method call")
   )
  )

(define test-cases-named-class-field-ref/set
  (list
   (list "
class c1 extends object
  field x
  field y
  method initialize()
    begin
      set x = 1;
      set y = 2
    end


class c2 extends c1
  field x
  field y
  method initialize()
    begin
      super initialize();
      set x = 3;
      set y = 4
    end

let o = new c2()
  in list(named-fieldref c1 o x, named-fieldref c1 o y, named-fieldref c2 o x, named-fieldref c2 o y)
            " '(1 2 3 4) "named-fieldref gets named class field of an object")

   (list "
class c1 extends object
  field x
  field y
  method initialize()
    begin
      set x = 1;
      set y = 2
    end


class c2 extends c1
  field x
  field y
  method initialize()
    begin
      super initialize();
      set x = 3;
      set y = 4
    end

let o = new c2()
  in begin
    named-fieldset c1 o x = 5;
    named-fieldset c1 o y = 6;
    list(named-fieldref c1 o x, named-fieldref c1 o y)
  end
               " '(5 6) "named-fieldset sets named class field of an object")
   )
  )

(define test-cases-exer-9.10
  (append
   test-cases-named-method-call
   test-cases-named-class-field-ref/set
   )
  )

(define test-cases-exer-method-visibility
  (list
   (list "
class c1 extends object
  public method initialize() 0
  method m1 () 1

let o1 = new c1()
  in send o1 m1()
            " 1 "public method m1 which can be used outside class c1")

   (list "
class c1 extends object
  method initialize() 0
  private method m1 () 1

let o1 = new c1()
  in send o1 m1()
            " 'error "private method m1 cannot be called outside.")

   (list "
class c1 extends object
  method initialize() 0
  private method m1 () 1
  method m2() send self m1()

let o1 = new c1()
  in send o1 m2()
            " 1 "private method m1 can be called inside host class c1 method m2")

   (list "
class c1 extends object
  method initialize() 0
  protected method m1 () 1

let o1 = new c1()
  in send o1 m1()
            " 'error "protected method m1 cannot be called in global env")

   (list "
class c1 extends object
  method initialize() 0
  protected method m1 () 1
  method m2() send self m1()

let o1 = new c1()
  in send o1 m2()
            " 1 "protected method m1 can be called inside host class c1 method m2")

   (list "
class c1 extends object
  method initialize() 0
  protected method m1 () 1

class c2 extends c1
  method m3() send self m1()

let o2 = new c2()
  in send o2 m3()
            " 1 "protected method m1 can be called in subclass c2 method m3")

   (list "
class c1 extends object
  protected method initialize() 0

let o1 = new c1()
  in 1
            " 'error "class m1 with protected method initialize cannot be instantiated")

   (list "
class c1 extends object
  private method initialize() 0

let o1 = new c1()
  in 1
            " 'error "class m1 with private method initialize cannot be instantiated")

   (list "
class c1 extends object
  method initialize() 0
  private method m1 () 1

class c2 extends c1
  method m2() super m1()

let o2 = new c2()
  in send o2 m2()
            " 'error "private super method m1 cannot be called in c2 m2")
   )
  )

(define test-cases-exer-field-visibility
  (list
   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      fieldset x = initx;
      fieldset y = inity
    end
  method move (dx, dy)
    begin
      fieldset x = +(fieldref x,dx);
      fieldset y = +(fieldref y,dy)
    end
  method get-location ()
    list(x,y)
let p = new point(3, 4)
  in send p get-location()
            " '(3 4) "fieldref and fieldset")

   (list "
class point extends object
  public-field x
  public-field y
  method initialize (initx, inity)
    begin
      fieldset x = initx;
      fieldset y = inity
    end
  method move (dx, dy)
    begin
      fieldset x = +(fieldref x,dx);
      fieldset y = +(fieldref y,dy)
    end
  method get-location ()
    list(x,y)

class colorpoint extends point
  field color
  method initialize (initx, inity, initcolor)
    begin
      fieldset x = initx;
      fieldset y = inity;
      set color = initcolor
    end
  method set-color (c)
    set color = c
  method get-color ()
    color

let p = new colorpoint(3, 4, 77)
  in list(send p get-location(), send p get-color())
            " '((3 4) 77) "public field x/y can be accessed in subclass")

   (list "
class point extends object
  protected-field x
  protected-field y
  method initialize (initx, inity)
    begin
      fieldset x = initx;
      fieldset y = inity
    end
  method move (dx, dy)
    begin
      fieldset x = +(fieldref x,dx);
      fieldset y = +(fieldref y,dy)
    end
  method get-location ()
    list(x,y)

class colorpoint extends point
  field color
  method initialize (initx, inity, initcolor)
    begin
      fieldset x = initx;
      fieldset y = inity;
      set color = initcolor
    end
  method set-color (c)
    set color = c
  method get-color ()
    color

let p = new colorpoint(3, 4, 77)
  in list(send p get-location(), send p get-color())
            " '((3 4) 77) "protected field x/y can be accessed in subclass")

   (list "
class point extends object
  private-field x
  private-field y
  method initialize (initx, inity)
    begin
      fieldset x = initx;
      fieldset y = inity
    end
  method move (dx, dy)
    begin
      fieldset x = +(fieldref x,dx);
      fieldset y = +(fieldref y,dy)
    end
  method get-location ()
    list(x,y)

class colorpoint extends point
  field color
  method initialize (initx, inity, initcolor)
    begin
      fieldset x = initx;
      fieldset y = inity;
      set color = initcolor
    end
  method set-color (c)
    set color = c
  method get-color ()
    color

let p = new colorpoint(3, 4, 77)
  in list(send p get-location(), send p get-color())
            " 'error "private field x/y cannot be accessed in subclass")
   )
  )

(define test-cases-exer-final-method
  (list
   (list "
class oddeven extends object
  method initialize () 1
  final method even (n)
    if zero?(n)
    then 1
    else send self odd(-(n,1))
  final method odd (n)
    if zero?(n)
    then 0
    else send self even(-(n,1))

class bogus-oddeven extends oddeven
    method even()
        0

1
            " 'error "final method cannot be overridden")
   )
  )

(define test-cases-exer-9.14
  (list
   (list "
class c1 extends object
  method initialize() 0
  method m1() send self m2()
  method m2() 2

class c2 extends c1
  method m2() 20

let o2 = new c2()
  in send o2 m1()
            " 2 "m1() calls host class c1.m2() instead of c2.m2")
   )
  )

(define test-cases-exer-static-class-field
  (list
   (list "
class c1 extends object
  static next-serial-number = 1
  field my-serial-number
  method get-serial-number() my-serial-number
  method initialize()
    begin
      set my-serial-number = next-serial-number;
      set next-serial-number = +(next-serial-number, 1)
    end

let o1 = new c1()
    o2 = new c1()
  in list(send o1 get-serial-number(), send o2 get-serial-number())
            " '(1 2) "static class field")

   (list "
class c1 extends object
  static next-serial-number = a
  field my-serial-number
  method get-serial-number() my-serial-number
  method initialize()
    begin
      set my-serial-number = next-serial-number;
      set next-serial-number = +(next-serial-number, 1)
    end

let o1 = new c1()
    o2 = new c1()
  in list(send o1 get-serial-number(), send o2 get-serial-number())
            " 'error "static class field must be constant, only num-exp is allowed now.")
   )
  )

(define test-cases-exer-method-overloading
  (list
   (list "
class c1 extends object
  field x
  method initialize()
    begin
      set x = 0
    end

  method initialize(val)
    begin
      set x = val
    end

  method get-x() x

let o1 = new c1()
    o2 = new c1(42)
  in list(send o1 get-x(), send o2 get-x())
            " '(0 42) "'initialize' method overloading")

   )
  )

(define test-cases-local-class
  (list
   (list "
class interior-node extends object
  field left
  field right
  method initialize (l, r)
    begin
      set left = l;
      set right = r
    end
  method sum ()
    +(send left sum(),send right sum())

class leaf-node extends object
  field value
  method initialize (v)
    set value = v
  method sum ()
    value
let o1 = new interior-node(
               new interior-node(
                new leaf-node(3),
                new leaf-node(4)),
               new leaf-node(5))
  in send o1 sum()
            " 12 "local class environment")

   (list "
letclass interior-node extends object =
  field left
  field right
  method initialize (l, r)
    begin
      set left = l;
      set right = r
    end
  method sum ()
    +(send left sum(),send right sum())

  in letclass leaf-node extends object =
    field value
    method initialize (v)
      set value = v
    method sum ()
      value
    in let o1 = new interior-node(
               new interior-node(
                new leaf-node(3),
                new leaf-node(4)),
               new leaf-node(5))
      in send o1 sum()
            " 12 "letclass expression")
   )
  )

(define test-cases-exer-9.25
  (list
   (list "equal?(1, 1)" #t "equal?(1, 1) is true")
   (list "equal?(0, 1)" #f "equal?(1, 0) is false")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then equal?(send pt getcolor(), color)
    else zero?(1)
let c1 = new point(1, 2)
    c2 = new point(1, 2)
  in send c1 similarpoints (c2)
            " #t "similarpoints(point, point) is true")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then equal?(send pt getcolor(), color)
    else zero?(1)
let c1 = new point(1, 2)
    c2 = new colorpoint(1, 2, 255)
  in send c1 similarpoints (c2)
            " #t "similarpoints(point, colorpoint) is true")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then equal?(send pt getcolor(), color)
    else zero?(1)
let c1 = new colorpoint(1, 2, 255)
    c2 = new colorpoint(1, 2, 255)
  in send c1 similarpoints (c2)
            " #t "similarpoints(colorpoint, colorpoint) is true")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then equal?(send pt getcolor(), color)
    else zero?(1)
let c1 = new colorpoint(1, 2, 255)
    c2 = new point(1, 2)
  in send c1 similarpoints (c2)
            " 'error "similarpoints(colorpoint, point) is error, point treated as colorpoint, method getcolor not found")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then
      if instanceof pt colorpoint
      then equal?(send pt getcolor(), color)
      else zero?(0)
    else zero?(1)
let c1 = new colorpoint(1, 2, 255)
    c2 = new point(1, 2)
  in send c1 similarpoints (c2)
            " #t "use instanceof operator to check is second argument pt is also colorpoint")

   (list "
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color

let similarpoint = proc (pt1, pt2)
                      if equal?(send pt1 getx(), send pt2 getx())
                      then equal?(send pt1 gety(), send pt2 gety())
                      else zero?(1)
  in let similarcolorpoint = proc (cpt1, cpt2)
                              if (similarpoint cpt1 cpt2)
                              then if instanceof cpt1 colorpoint
                                   then if instanceof cpt2 colorpoint
                                        then equal?(send cpt1 getcolor(), send cpt2 getcolor())
                                        else zero?(0)
                                   else zero?(0)
                              else zero?(1)
    in let c1 = new colorpoint(1, 2, 255)
           c2 = new point(1, 2)
          in (similarcolorpoint c1 c2)
            " #t "use a procedure instead of method to avoid binary method problem")
   )
  )

(define test-cases-exer-9.27
  (list
   (list "
let make-oddeven = proc ()
                    newobject
                      even = proc (n) if zero?(n) then 1 else (getmethod(self, odd) -(n,1))
                      odd  = proc (n) if zero?(n) then 0 else (getmethod(self, even) -(n,1))
                    endnewobject
in let o1 = (make-oddeven)
  in (getmethod(o1, odd) 13)
            " 1 "object language without class")
   )
  )

(define test-cases-exer-9.28
  (append
   test-cases-exer-9.27
   (list
    (list "
let make-base = proc()
                  newobject
                    index = proc () 42
                  endnewobject
  in let base-object = (make-base)
      in let make-oddeven = proc ()
                          newobject inherits base-object
                            even = proc (n) if zero?(n) then 1 else (getmethod(self, odd) -(n,1))
                            odd  = proc (n) if zero?(n) then 0 else (getmethod(self, even) -(n,1))
                          endnewobject
        in let o1 = (make-oddeven)
          in (getmethod(o1, index))
            " 42 "support object inheritance throught keyword 'inherits'")
    )
   )
  )

(define test-cases-typed-list
  (append
   test-cases-exer-7.9-list
   (list
    (list "car(cons(1, emptylist_ int))" 1 "car-exp")
    (list "car(emptylist_ int)" '() "car-exp")

    (list "cdr(cons(1, emptylist_ int))" '() "cdr-exp")
    (list "cdr(emptylist_ int)" '() "cdr-exp")
    )
   )
  )

(define test-cases-typed-oo
  (list
   (list "
interface tree
  method int sum()
  method bool equal(t: tree)

class interior-node extends object implements tree
  field tree left
  field tree right
  method void initialize(l: tree, r: tree)
    begin
      set left = l;
      set right = r
    end

  method tree getleft() left
  method tree getright() right
  method int sum()
    +(send left sum(), send right sum())
  method bool equal(t: tree)
    if instanceof t interior-node
    then if send left equal(send cast t interior-node getleft())
         then send right equal(send cast t interior-node getright())
         else zero?(1)
    else zero?(1)

class leaf-node extends object implements tree
  field int value
  method void initialize(v: int)
    set value = v
  method int sum() value
  method int getvalue() value
  method bool equal(t: tree)
    if instanceof t leaf-node
    then zero?(-(value, send cast t leaf-node getvalue()))
    else zero?(1)

let o1 = new interior-node(
            new interior-node(new leaf-node(3), new leaf-node(4)),
            new leaf-node(5))
  in list(send o1 sum(), if send o1 equal(o1) then 100 else 200)
            " '(12 100) "Figure 9.12 A sample program in TYPED-OO")
   )
  )

(define test-cases-9.30
  (list
   (list "
interface summable
  method int sum()

class summable_list extends object implements summable
  field summable head
  field summable_list tail

  method void initialize(l: summable, r: summable_list)
    begin
      set head = l;
      set tail = r
    end

  method int sum()
    +(send head sum(), send tail sum())

class empty_summable_list extends summable_list
  % override parent constructor
  % not checking constructor type
  method int initialize() 1
  method int sum() 0

class summable_node extends object implements summable
  field int value
  method void initialize(val: int)
    set value = val
  method int sum() value

let l1 = new empty_summable_list()
  in let l2 = new summable_node(4)
    in let l3 = new summable_list(l2, l1)
      in let l4 = new summable_list(l2, l3)
        in list(send l1 sum(), send l2 sum(), send l3 sum(), send l4 sum())
            " '(0 4 4 8) "summable list")

   (list "
interface summable
  method int sum()

class summable_binary_tree extends object implements summable
  field summable head
  field summable tail

  method void initialize(l: summable, r: summable)
    begin
      set head = l;
      set tail = r
    end

  method int sum()
    +(send head sum(), send tail sum())

class summable_node extends object implements summable
  field int value
  method void initialize(val: int)
    set value = val
  method int sum() value

let t1 = new summable_node(1)
  in let t2 = new summable_node(2)
    in let t3 = new summable_binary_tree(t1, t2)
      in let t4 = new summable_binary_tree(t2, t3)
        in list(send t1 sum(), send t2 sum(), send t3 sum(), send t4 sum())
            " '(1 2 3 5) "summable binary tree")

   (list "
interface summable
  method int sum()

class summable_general_tree extends object implements summable
  field listof summable children

  method void initialize(c: listof summable)
    set children = c

  method int sum()
    letrec int get-sum (c: listof summable) = if null?(c)
                                              then 0
                                              else +(send car(c) sum(), (get-sum cdr(c)))
      in (get-sum children)

class summable_node extends object implements summable
  field int value
  method void initialize(val: int)
    set value = val
  method int sum() value

let n1 = new summable_node(1)
  in let n2 = new summable_node(2)
    in let n3 = new summable_node(3)
      in let l1 = list(n1, n2, n3)
        in let tree = new summable_general_tree(l1)
          in list(send n1 sum(), send n2 sum(), send n3 sum(), send tree sum())
            " '(1 2 3 6) "summable general tree")
   )
  )

(define test-cases-9.32
  (list
   (list "
interface tree
  method int sum()
  method bool equal(t: tree)
  method bool equal_with_interior_node(t: interior-node)
  method bool equal_with_leaf_node(t: leaf-node)

class interior-node extends object implements tree
  field tree left
  field tree right
  method void initialize(l: tree, r: tree)
    begin
      set left = l;
      set right = r
    end

  method tree getleft() left
  method tree getright() right
  method int sum()
    +(send left sum(), send right sum())

  method bool equal(t: tree)
    send t equal_with_interior_node (self)

  method bool equal_with_interior_node (t: interior-node)
    if send left equal (send t getleft())
    then send right equal (send t getright())
    else zero?(1)

  method bool equal_with_leaf_node (t: leaf-node)
    zero?(1)

class leaf-node extends object implements tree
  field int value
  method void initialize(v: int)
    set value = v
  method int sum() value
  method int getvalue() value

  method bool equal(t: tree)
    send t equal_with_leaf_node (self)

  method bool equal_with_interior_node(t: interior-node)
    zero?(1)

  method bool equal_with_leaf_node(t: leaf-node)
    zero?(-(value, send t getvalue()))

let l1 = new leaf-node(1)
in let l2 = new leaf-node(2)
in let i1 = new interior-node(l1, l2)
in let i2 = new interior-node(l1, i1)
in list(
  send l1 equal (l1),
  send l1 equal (l2),
  send l1 equal (i1),
  send i1 equal (i1),
  send i1 equal (i2),
  send i1 equal (l1)
)
            " '(#t #f #f #t #f #f) "equal method by double dispatch")
   )
  )

(define test-cases-9.33-9.34-instanceof
  (list
   (list "
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let c = new child()
in instanceof c child
             " #t "child is instance of its class")

   (list "
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let c = new child()
in instanceof c parent
             " #t "child is instance of its ancestor class")

   (list "
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let p = new parent()
in instanceof p child
             " #f "p is not instance of its sub class")
   )
  )

(define test-cases-9.33-9.34-cast
  (list
   (list "
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let c = new child()
in let test-cast = proc (p: parent) send cast p child value()
in list((test-cast c))
             " '(2) "cast parent to child")

   (list "
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let c = new child()
in cast c parent
            " 'error "no need to cast to parent type, error on this")

   (list "
class Animal extends object
  method int initialize() 1

class Fruit extends object
  method int initialize() 2

let f = new Fruit()
in cast f Animal
            " 'error "error when cast to class type with no inheritance relationship")

   (list "
class Animal extends object
  method int initialize() 1

class Fruit extends object
  method int initialize() 2

cast 1 Animal
            " 'error "can only cast object")
   )
  )

(define test-cases-9.33-9.34
  (append
   test-cases-9.33-9.34-instanceof
   test-cases-9.33-9.34-cast
   )
  )

(define test-cases-exer-9.35
  (list
   (list "
class animal extends object
  method int initialize() 1

let a = new animal()
  in 1
             " 1 "ok to use new operator calls initialize implicitly")

   (list "
class animal extends object
  method int initialize() 1

let a = new animal()
  in send a initialize()
             " 'error "invalid initialize in normal method call")

   (list "
class animal extends object
  method int initialize() 1

class panda extends animal
  method int initialize()
    super initialize()

let a = new panda()
  in 1
             " 1 "ok to use initialize in super call")
   )
  )

(define test-cases-exer-9.37
  (list
   (list "
class c1 extends object
  method int initialize() 1
  method int m1() 11
  staticmethod int m2() 21

class c2 extends c1
  method int m1() 12
  staticmethod int m2() 22

let f = proc(x: c1) send x m1()
    g = proc(x: c1) send x m2()
    o = new c2()
in list((f o), (g o))
             " '(12 21) "static method uses static dispatch")
   )
  )

(define test-cases-exer-9.42
  (list
   (list "
class c1 extends object
  method int initialize() 1
  staticmethod int m1() 11

class c2 extends c1
  method int initialize() 2
  method int m1() 12

1
             " 'error "dynamic method c2.m1 cannot override static method c1.m1")

   (list "
class c1 extends object
  method int initialize() 1
  method int m1() 11

class c2 extends c1
  method int initialize() 2
  staticmethod int m1() 12

1
             " 'error "static method c2.m1 cannot override dynamic method c1.m1")
   )
  )

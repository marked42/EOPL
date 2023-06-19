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

(define test-cases-exer-7.9
  (append
   test-cases-checked-lang
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

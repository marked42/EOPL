#lang eopl

(require racket racket/list rackunit)
(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")
(require "inferrer/main.rkt" "inferrer/equal-up-to-gensyms.rkt")

(test-lang run sloppy->expval test-cases-checked-lang)

(define (test-inferrer-cases test-cases)
  (let ([equal-answer? (lambda (ans correct-ans msg) (check-equal? ans correct-ans msg))])
    (map (lambda (test-case)
           (let ([source (first test-case)] [expected (second test-case)] [msg (third test-case)])
             (if (equal? expected 'error)
                 (check-exn exn:fail? (lambda () (check-program-type source)))
                 (let ([prog-type (check-program-type source)])
                   (equal-answer? (apply-subst-to-sexp (canonical-subst prog-type) prog-type) expected msg)
                   )
                 )
             )
           ) test-cases)
    )
  )

(define test-cases-simple-arithmetic
  (list
   (list "1" 'int "positive const")
   (list "-1" 'int "negative const")
   )
  )

(define test-cases-nested-arithmetic
  (list
   (list "-(-(44, 33), 22)" 'int "nested arithmetic left")
   (list "-(55, -(22, 11))" 'int "nested arithmetic right")
   )
  )

(define test-cases-simple-variables
  (list
   (list "x" 'int "test-var-1")
   (list "-(x,1)" 'int "test-var-2")
   (list "-(1,x)" 'int "test-var-3")

   (list "zero?(-(3,2))" 'bool "zero-test-1")
   (list "-(2, zero?(0))" 'error "zero-test-2")
   )
  )

(define test-cases-simple-unbound-variables
  (list
   (list "foo" 'error "test-unbound-var-1")
   (list "-(x, foo)" 'error "test-unbound-var-2")
   )
  )

(define test-cases-simple-conditionals
  (list
   (list "if zero?(1) then 3 else 4" 'int "if-true")
   (list "if zero?(0) then 3 else 4" 'int "if-false")

   (list "if zero?(-(11,12)) then 3 else 4" 'int "if-eval-test-true")
   (list "if zero?(-(11,11)) then 3 else 4" 'int "if-eval-test-false")
   (list "if zero?(1) then -(22,1) else -(22,2)" 'int "if-eval-then")
   (list "if zero?(0) then -(22,1) else -(22,2)" 'int "if-eval-else")

   (list "if zero?(0) then 1 else zero?(1)" 'error "if-compare-arms")
   (list "if 1 then 11 else 12" 'error "if-check-test-is-boolean")
   )
  )

(define test-cases-simple-let
  (list
   (list "let x = 3 in x" 'int "simple-let-1")
   (list "let x = 3 in -(x,1)" 'int "eval-let-body")
   (list "let x = -(4,1) in -(x,1)" 'int "eval-let-rhs")
   )
  )

(define test-cases-nested-let
  (list
   (list "let x = 3 in let y = 4 in -(x, y)" 'int "simple-nested-let")
   (list "let x = 3 in let x = zero?(1) in x" 'bool "shadowing")
   (list "let x = 3 in let x = zero?(x) in x" 'bool "shadowing")
   (list "let x = 3 in let x = 4 in x" 'int "check-shadowing-in-body")
   (list "let x = 3 in let x = 4 in -(x,1)" 'int "check-shadowing-in-rhs")
   )
  )

(define test-cases-simple-applications
  (list
   (list "(proc (x: int) -(x,1) 30)" 'int "apply-proc-in-rator-pos")
   (list "(proc (x: (int -> int)) -(x,1) 30)" 'error "check doesn't ignore type info in proc")
   (list "let f = proc (x: int) -(x,1) in (f 30)" 'int "apply simple proc")
   (list "(proc (f: (int -> int)) (f 30) proc (x: int) -(x,1))" 'int "let to proc 1")

   (list "((proc (x: int) proc (y: int) -(x,y) 5) 6)" 'int "nested procs")
   (list "let f = proc (x: int) proc (y: int) -(x,y) in ((f -(10, 5)) 3)" 'int "nested procs 2")
   )
  )

(define test-cases-simple-letrecs
  (list
   (list "
letrec int f(x: int) = -(x,1) in (f 33)
" 'int "simple letrec 1")

   (list "
letrec int f(x: int) = if zero?(x) then -((f -(x,1)), -2) else 0
  in (f 4)
" 'int "simple letrec 2")

   (list "
let m = -5
  in letrec int f(x: int) = if zero?(x) then -((f -(x,1)), m) else 0
    in (f 4)
" 'int "simple letrec 3")

   (list "
letrec int double (n: int) = if zero?(n) then 0 else -((double -(n,1)), -2)
  in (double 3)
" 'int "double it")
   )
  )

(define test-cases-procedures
  (list
   (list "proc (x: int) -(x,1)" '(int -> int) "build a proc")
   (list "proc (x: int) zero?(-(x,1))" '(int -> bool) "build a proc")
   (list "let f = proc (x: int) -(x,1) in (f 4)" 'int "build a proc")
   (list "let f = proc (x: int) -(x,1) in f" '(int -> int) "build a proc returning proc")

   (list "proc (f: (int -> bool)) (f 3)" '((int -> bool) -> bool) "type a ho proc 1")
   (list "proc (f: (bool -> bool)) (f 3)" 'error "type a ho proc 2")

   (list "proc (x: int) proc (f: (int -> bool)) (f x)" '(int -> ((int -> bool) -> bool)) "apply a ho proc")
   (list "proc (x: int) proc (f: (int -> (int -> bool))) (f x)" '(int -> ((int -> (int -> bool)) -> (int -> bool))) "apply a ho proc 2")

   (list "((proc (x: int) proc (y: int) -(x,y) 3) 4)" 'int "apply curried proc")
   (list "(proc (x: int) -(x,1) 4)" 'int "apply proc")

   (list "letrec int f(x: int) = -(x,1) in (f 40)" 'int "apply a letrec")

   (list "(proc (x: int) letrec bool loop(x: bool) = (loop x) in x 1)" 'int "letrec non shadowing")

   (list "
let times = proc (x: int) proc (y: int) -(x,y) % not really times
  in letrec int fact (x: int) = if zero?(x) then 1 else ((times x) (fact -(x,1)))
    in fact
" '(int -> int) "letrec return fact")

   (list "
let times = proc (x: int) proc (y: int) -(x,y) % not really times
  in letrec int fact (x: int) = if zero?(x) then 1 else ((times x) (fact -(x,1)))
    in (fact 4)
" 'int "letrec apply fact")

   (list "
letrec ? fact(x: ?) = if zero?(x) then 1 else -(x, (fact -(x,1)))
  in fact
" '(int -> int) "pgm7b")
   )
  )

(define test-cases-circular-types
  (list
   (list "letrec ? f(x: ?) = (f f) in 33" 'error "dont infer circular")
   )
  )

(define test-cases-polymorphic
  (list
   (list "letrec ? f(x: ?) = (f x) in f" '(tvar0 -> tvar1) "polymorphic type")
   )
  )

(define test-cases-let-exp-with-multiple-declarations
  (list
   (list "let a = 1 b = 2 in -(a, b)" 'int "let exp with multiple declarations")
   (list "
let x = 30
      in let x = -(x,1)
             y = -(x,2)
         in -(x,y)
   " 'int "let exp with multiple declarations")
   )
  )

(define test-cases-inferrer-lang
  (append
   test-cases-simple-arithmetic
   test-cases-nested-arithmetic
   test-cases-simple-variables
   test-cases-simple-unbound-variables
   test-cases-simple-conditionals
   test-cases-simple-let
   test-cases-nested-let
   test-cases-simple-applications
   test-cases-simple-letrecs
   test-cases-procedures
   test-cases-circular-types
   test-cases-polymorphic

   test-cases-let-exp-with-multiple-declarations
   )
  )

(test-inferrer-cases test-cases-inferrer-lang)

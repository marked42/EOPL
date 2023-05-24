#lang eopl

(require racket/lazy-require rackunit)
(lazy-require
 ["../cps-lang/formatter.rkt" (format-cps-program)]
 ["../cps-lang/parser.rkt" (scan&parse)]
 )

(provide (all-defined-out))

(define (test-transformer transform)
  (test-transform-const-exp transform)
  (test-transform-var-exp transform)
  (test-transform-diff-exp transform)
  (test-transform-zero?-exp transform)
  (test-transform-call-exp transform)
  (test-transform-sum-exp transform)
  (test-transform-if-exp transform)
  (test-transform-proc-exp transform)
  (test-transform-let-exp transform)
  (test-transform-letrec-exp transform)
  )

(define (test-transform-exp transform input expected message)
  (check-equal? (format-cps-program (transform (scan&parse input))) expected message)
  )

(define (test-transform-const-exp transform)
  (test-transform-exp transform "1" "1" "const-exp")
  )

(define (test-transform-var-exp transform)
  (test-transform-exp transform "a" "a" "var-exp")
  )

(define (test-transform-diff-exp transform)
  (test-transform-exp transform "-(1,2)" "-(1, 2)" "diff-exp")
  (test-transform-exp transform "-((a 1), (b 2))" "(a 1 proc (var%2) (b 2 proc (var%3) (proc (var%1) var%1 -(var%2, var%3))))" "diff-exp")
  )

(define (test-transform-zero?-exp transform)
  (test-transform-exp transform "zero?(0)" "zero?(0)" "zero?-exp")
  (test-transform-exp transform "zero?((a 1))" "(a 1 proc (var%2) (proc (var%1) var%1 zero?(var%2)))" "zero?-exp")
  )

(define (test-transform-call-exp transform)
  (test-transform-exp transform "(a 1 2)" "(a 1 2 proc (var%1) var%1)" "call-exp")
  (test-transform-exp transform "((a 1) 2)" "(a 1 proc (var%2) (var%2 2 proc (var%1) var%1))" "call-exp")
  (test-transform-exp transform "((a 1) (b 2))" "(a 1 proc (var%2) (b 2 proc (var%3) (var%2 var%3 proc (var%1) var%1)))" "call-exp")
  )

(define (test-transform-sum-exp transform)
  (test-transform-exp transform "+((a 1), (b 2))" "(a 1 proc (var%2) (b 2 proc (var%3) (proc (var%1) var%1 +(var%2, var%3))))" "sum-exp")
  )

(define (test-transform-if-exp transform)
  (test-transform-exp transform "if zero?(0) then 2 else 3" "if zero?(0) then (proc (var%1) var%1 2) else (proc (var%1) var%1 3)" "if-exp")
  (test-transform-exp transform "if (a 1) then (p x) else (p y)" "(a 1 proc (var%2) if var%2 then (p x proc (var%1) var%1) else (p y proc (var%1) var%1))" "if-exp")
  )

(define (test-transform-proc-exp transform)
  (test-transform-exp transform "proc (x) (x 1)" "proc (x, k%00) (x 1 k%00)" "proc-exp")
  )

(define (test-transform-let-exp transform)
  (test-transform-exp transform "let x = (p 1) in (x 2)" "(p 1 proc (var%2) let x = var%2 in (x 2 proc (var%1) var%1))" "let-exp")
  (test-transform-exp transform "let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)" "let f = proc (x, k%00) (k%00 proc (y, k%00) (k%00 -(x, -(0, y)))) in (f 3 proc (var%2) (var%2 4 proc (var%1) var%1))" "let-exp")
  (test-transform-exp transform "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)" "let f = proc (x, y, k%00) (k%00 -(x, -(0, y))) in (f 3 4 proc (var%1) var%1)" "let-exp")
  (test-transform-exp transform "let a = 1 in -(a, x)" "let a = 1 in (proc (var%1) var%1 -(a, x))" "let-exp")
  (test-transform-exp transform "let f = proc (x) -(x,11) in (f (f 77))" "let f = proc (x, k%00) (k%00 -(x, 11)) in (f 77 proc (var%2) (f var%2 proc (var%1) var%1))" "let-exp")
  )

(define (test-transform-letrec-exp transform)
  (test-transform-exp transform "letrec double(x) = if zero?(x) then 0 else -((double -(x,1)), -2) in (double 6)" "letrec double(x, k%00) = if zero?(x) then (k%00 0) else (double -(x, 1) proc (var%2) (k%00 -(var%2, -2))) in (double 6 proc (var%1) var%1)" "letrec-exp")
  (test-transform-exp transform "letrec sum1(x, y) = if zero?(x) then y else -((sum1 -(x,1) y), -1) in (sum1 3 4)" "letrec sum1(x, y, k%00) = if zero?(x) then (k%00 y) else (sum1 -(x, 1) y proc (var%2) (k%00 -(var%2, -1))) in (sum1 3 4 proc (var%1) var%1)" "letrec-exp")
  (test-transform-exp transform "letrec even(x) = if zero?(x) then 1 else (odd -(x,1)) odd(x) = if zero?(x) then 0 else (even -(x,1)) in (odd 13)" "letrec even(x, k%00) = if zero?(x) then (k%00 1) else (odd -(x, 1) k%00) odd(x, k%00) = if zero?(x) then (k%00 0) else (even -(x, 1) k%00) in (odd 13 proc (var%1) var%1)" "letrec-exp with multiple procedures")
  (test-transform-exp transform "letrec f1(x1) = (x1 1) f2(x2) = (x2 2) in (f1 f2)" "letrec f1(x1, k%00) = (x1 1 k%00) f2(x2, k%00) = (x2 2 k%00) in (f1 f2 proc (var%1) var%1)" "letrec-exp with multiple procedures")
  )

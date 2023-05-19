#lang eopl

(require rackunit)
(require racket)
(require "interpreter.rkt")
(require "value.rkt")

(define equal-answer?
  (lambda (ans correct-ans msg)
    (check-equal? ans (sloppy->expval correct-ans) msg)))

(define sloppy->expval
  (lambda (sloppy-val)
    (cond
      ((number? sloppy-val) (num-val sloppy-val))
      ((boolean? sloppy-val) (bool-val sloppy-val))
      (else
       (eopl:error 'sloppy->expval
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))

(define (test-const-exp run)
  (equal-answer? (run "1") 1 "const exp")
  (equal-answer? (run "1") 1 "const exp")
  )

(define (test-diff-exp run)
  (equal-answer? (run "-(1, 2)") -1 "diff exp")
  )

(define (test-zero?-exp run)
  (equal-answer? (run "zero? (0)") #t "zero? exp")
  (equal-answer? (run "zero? (1)") #f "zero? exp")
  )

(define (test-var-exp run)
  (equal-answer? (run "i") 1 "built in var i is 1")
  (equal-answer? (run "v") 5 "built in var i is 5")
  (equal-answer? (run "x") 10 "built in var i is 10")
  )

(define (test-if-exp run)
  (equal-answer? (run "if zero? (0) then 2 else 3") 2 "if exp")
  (equal-answer? (run "if zero? (1) then 2 else 3") 3 "if exp")
  )

(define (test-let-exp run)
  (equal-answer? (run "let a = 1 in -(a, x)") -9 "let exp")
  (equal-answer? (run "let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)") 7 "let-exp with call-exp")
  (equal-answer? (run "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)") 7 "letexp with call-exp")
  )

(define (test-proc-and-call-exp run)
  (run "proc (x) x")
  (equal-answer? (run "(proc (f) (f (f 77)) proc (x) -(x,11))") 55 "call-exp with single arguemnt")
  (equal-answer? (run "let f = proc (x) -(x,11) in (f (f 77))") 55 "proc-exp")
  )

(define (test-call-exp-with-multiple-arguments run)
  (equal-answer? (run "(proc (x, y) -(x,y) 2 3)") -1 "call-exp with multiple arguments")
  )

(define (test-letproc-exp run)
  (equal-answer? (run "let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)") 7 "letproc-exp")
  (equal-answer? (run "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)") 7 "letproc-exp")
  )

(define (test-letrec-exp run)
  (equal-answer? (run "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 6)
") 12 "letrec-exp")
  )

(define (test-extended-letrec-exp run)
  (equal-answer? (run "
letrec sum1(x, y)
  = if zero?(x) then y else -((sum1 -(x,1) y), -1)
    in (sum1 3 4)
") 7 "letrec-exp with multiple arguments")

  ; (odd 13) -> (even 12) -> (odd 11) -> ... -> (even 0) -> 1
  (equal-answer? (run "
letrec
even(x) = if zero?(x) then 1 else (odd -(x,1))
odd(x) = if zero?(x) then 0 else (even -(x,1))
in (odd 13)
") 1 "letrec-exp with multiple procedures")
  )

(define (test-let-lang run)
  (test-const-exp run)
  (test-diff-exp run)
  (test-zero?-exp run)
  (test-var-exp run)
  (test-if-exp run)
  (test-proc-and-call-exp run)
  (test-call-exp-with-multiple-arguments run)
  (test-let-exp run)
  (test-letproc-exp run)
  (test-letrec-exp run)
  (test-extended-letrec-exp run)
  )

(test-let-lang run)

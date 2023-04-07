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

(equal-answer? (run "1") 1 "const exp")
(equal-answer? (run "-(1, 2)") -1 "diff exp")
(equal-answer? (run "zero? (0)") #t "zero? exp")
(equal-answer? (run "zero? (1)") #f "zero? exp")
(equal-answer? (run "if zero? (0) then 2 else 3") 2 "if exp")
(equal-answer? (run "if zero? (1) then 2 else 3") 3 "if exp")
(equal-answer? (run "i") 1 "built in var i is 1")
(equal-answer? (run "v") 5 "built in var v is 5")
(equal-answer? (run "x") 10 "built in var x is 10")
(equal-answer? (run "let a = 1 in -(a, x)") -9 "let exp")

(equal-answer? (run "let f = proc (x) -(x,11) in (f (f 77))") 55 "proc-exp")
; IIFE
(equal-answer? (run "(proc (f) (f (f 77)) proc (x) -(x,11))") 55 "proc-exp")

; exer 3.38
(equal-answer? (run "cond zero?(1) ==> 1 zero?(0) ==> 0 end") 0 "cond-exp")
(equal-answer? (run "cond zero?(0) ==> 0 zero?(1) ==> 1 end") 0 "cond-exp")
(check-exn exn:fail? (lambda () (run "cond zero?(1) ==> 1 zero?(2) ==> 2 end")))

(equal-answer? (run "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 0)
") 0 "letrec-exp")

(equal-answer? (run "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 1)
") 2 "letrec-exp")

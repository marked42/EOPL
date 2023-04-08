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
(equal-answer? (run "v") 5 "built in var i is 5")
(equal-answer? (run "x") 10 "built in var i is 10")
(equal-answer? (run "let a = 1 in -(a, x)") -9 "let exp")

; exer 3.16
(equal-answer? (run "let x = 30 in let x = -(x,1) y = -(x,2) in -(x,y)") 1 "let-exp with arbitrary number of vars")

(equal-answer? (run "let f = proc (x) -(x,11) in (f (f 77))") 55 "proc-exp")
; IIFE
(equal-answer? (run "(proc (f) (f (f 77)) proc (x) -(x,11))") 55 "proc-exp")

; exer 3.20
(equal-answer? (run "let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)") 7 "letproc-exp")

(equal-answer? (run "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)") 7 "letproc-exp")

(equal-answer? (run "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 6)
") 12 "letrec-exp")

(equal-answer? (run "
letrec sum(x, y)
  = if zero?(x) then y else -((sum -(x,1) y), -1)
    in (sum 3 4)
") 7 "letrec-exp with multiple arguments")

; (odd 13) -> (even 12) -> (odd 11) -> ... -> (even 0) -> 1
(equal-answer? (run "
letrec
even(x) = if zero?(x) then 1 else (odd -(x,1))
odd(x) = if zero?(x) then 0 else (even -(x,1))
in (odd 13)
") 1 "letrec-exp with multiple procedures")

(equal-answer? (run "
let x = 1
  in begin
       -(x, 1)
     end
") 0 "begin-exp")

(equal-answer? (run "
let x = newref(0)
      in letrec even()
                 = if zero?(deref(x))
                   then 1
                   else begin
                         setref(x, -(deref(x),1));
                         (odd)
                        end
                odd()
                 = if zero?(deref(x))
                   then 0
                   else begin
                         setref(x, -(deref(x),1));
                         (even)
                        end
         in begin setref(x,13); (odd) end
") 1 "explicit-refs")

(equal-answer? (run "
let a = newref(42)
  in let b = setref(a, 43)
    in deref(a)
") 43 "multiple newrefs")

(equal-answer? (run "
let g = let counter = newref(0)
          in proc (dummy)
            begin
              setref(counter, -(deref(counter), -1));
              deref(counter)
            end
  in let a = (g 11)
      in let b = (g 11)
        in -(a,b)
") -1 "closure")

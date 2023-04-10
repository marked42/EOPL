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

; ; update built in variable x
; (equal-answer? (run "
; begin
;   set x = 30;
;   x
; end
; ") 30 "begin-exp")

; ; update user defined variable
; (equal-answer? (run "
; let a = 25
;   in begin
;     set a = 19;
;     a
;   end
; ") 19 "begin-exp")

; ; update procedure parameter variable
; (equal-answer? (run "
; let f = proc (a, b)
;         begin
;           set a = -(a,-1);
;           -(a,b)
;          end
; in (f 44 33)") 12 "begin-exp")

; ; letrec variables
; (equal-answer? (run "
; letrec double(x) = x
;        triple(x) = x
;     in begin
;       set double = 17;
;       set triple = 20;
;       -(triple,double)
;     end
; ") 3 "letrec-exp")

; pass by ref
(equal-answer? (run "
let a = 1
  in let b = proc (x) setref(x, 3)
    in begin
      (b ref a);
      a
    end
") 3 "ref-exp")

; pass by value
(equal-answer? (run "
let a = 1
  in let b = proc (x) setref(x, 3)
    in begin
      (b a);
      a
    end
") 1 "ref-exp")

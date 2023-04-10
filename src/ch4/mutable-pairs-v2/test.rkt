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

(equal-answer? (run "
let glo = pair(11,22)
  in let f = proc (loc)
              let d1 = setright(loc, left(loc))
                 in let d2 = setleft(glo, 99)
                    in -(left(loc),right(loc))
      in (f glo)
") 88 "mutable-pair")

(equal-answer? (run "
let a = newarray(2,-99)
  in arraylength(a)
") 2 "array length")

(equal-answer? (run "
let a = newarray(2,-99)
  in arrayref(a, 0)
") -99 "arrayref")

(equal-answer? (run "
let a = newarray(2,-99)
  in arrayref(a, 1)
") -99 "arrayref")

(check-exn exn:fail? (lambda () (run "
let a = newarray(2,-99)
  in arrayref(a, 2)
")) "error when array ref index out of bounds")

(check-exn exn:fail? (lambda () (run "
let a = newarray(2,-99)
  in arrayref(a, -1)
")) "error when array ref index out of bounds")

(equal-answer? (run "
let a = newarray(2,-99)
  in begin
    arrayset(a, 0, 66);
    arrayref(a, 0)
  end
") 66 "array set")

(check-exn exn:fail? (lambda () (run "
let a = newarray(2,-99)
  in begin
    arrayset(a, -1, 66);
  end
")) "error when array set index out of bounds")

(check-exn exn:fail? (lambda () (run "
let a = newarray(2,-99)
  in begin
    arrayset(a, 2, 66);
  end
")) "error when array set index out of bounds")

(equal-answer? (run "
let a = newarray(2,-99)
    p = proc (x)
          let v = arrayref(x,1)
            in arrayset(x,1,-(v,-1))
  in begin
    arrayset(a,1,0);
    (p a);
    (p a);
    arrayref(a,1)
  end
") 2 "array")

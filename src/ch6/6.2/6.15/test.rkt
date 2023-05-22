#lang eopl

(require racket/lazy-require)
(lazy-require
 ["interpreter.rkt" (run)]
 ["value.rkt" (equal-answer?)]
 ["../../../base/test.rkt" (
                            test-const-exp
                            test-diff-exp
                            test-zero?-exp
                            test-var-exp
                            test-if-exp
                            test-call-exp-with-multiple-arguments
                            )]
 )

(provide (all-defined-out))

(define (test-sum-exp run equal-answer?)
  (equal-answer? (run "+(0)") 0 "sum-exp")
  (equal-answer? (run "+(1, 2, 3)") 6 "sum-exp")
  )

(define (test-proc-and-call-exp run equal-answer?)
  (run "proc (x) x")

  ; "(proc (f) (f (f 77)) proc (x) -(x,11))"
  (equal-answer? (run "
  (proc (f, v, cont)
    (f v proc (y)
      (f y proc (z)
        (cont z)
      ))
   proc (x, k1) (k1 -(x,11))
   77
   proc (z) z
  )"
                      ) 55 "call-exp with single arguemnt")

  ; let f = proc (x) -(x,11) in (f (f 77))
  (equal-answer? (run "
  let f = proc (x, k1) (k1 -(x, 11))
    in (f 77 proc (y)
             (f y proc (z)
                  z
             )
       )
  ") 55 "proc-exp")
  )

(define (test-let-exp run equal-answer?)
  (equal-answer? (run "let a = 1 in -(a, x)") -9 "let exp")

  ; let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)
  (equal-answer? (run "
  let f = proc (x, k1)
    (k1 proc (y, k2) (k2 -(x, -(0, y))))
    in (f 3 proc (r1)
      (r1 4 proc (r2)
        r2
      )
    )
  ") 7 "let-exp with call-exp")

  ; let f = proc(x, y) -(x,-(0,y)) in (f 3 4)
  (equal-answer? (run "
  let f = proc (x, y, k1) (k1 -(x, -(0,y)))
    in (f 3 4 proc (r1) r1)
  ") 7 "letexp with call-exp")
  )

(define (test-letrec-exp run equal-answer?)
  ; letrec double(x)
  ;   = if zero?(x) then 0 else -((double -(x,1)), -2)
  ;     in (double 6)
  (equal-answer? (run "
  letrec double(x, k1) =
    if zero?(x)
      then (k1 0)
      else (double -(x,1) proc(r1)
        (k1 -(r1,-2))
      )
    in (double 6 proc (z) z)
") 12 "letrec-exp")
  )

(define (test-extended-letrec-exp run equal-answer?)
  ; letrec sum1(x, y)
  ;   = if zero?(x) then y else -((sum1 -(x,1) y), -1)
  ;     in (sum1 3 4)
  (equal-answer? (run "
  letrec sum1(x, y, k1) =
    if zero?(x)
    then (k1 y)
    else (sum1 -(x,1) y proc (z)
      (k1 -(z,-1))
    )
  in (sum1 3 4 proc (z) z)
") 7 "letrec-exp with multiple arguments")

  ; (odd 13) -> (even 12) -> (odd 11) -> ... -> (even 0) -> 1
  ; letrec
  ; even(x) = if zero?(x) then 1 else (odd -(x,1))
  ; odd(x) = if zero?(x) then 0 else (even -(x,1))
  ; in (odd 13)
  (equal-answer? (run "
  letrec
    even(x, k1) = if zero?(x) then (k1 1) else (odd -(x,1) k1)
    odd(x, k1) = if zero?(x) then (k1 0) else (even -(x,1) k1)
    in (odd 13 proc (z) z)
") 1 "letrec-exp with multiple procedures")
  )


(define (test-cps-out-lang run equal-answer?)
  (test-const-exp run equal-answer?)
  (test-diff-exp run equal-answer?)
  (test-zero?-exp run equal-answer?)
  (test-var-exp run equal-answer?)
  (test-sum-exp run equal-answer?)
  (test-if-exp run equal-answer?)
  (test-call-exp-with-multiple-arguments run equal-answer?)
  (test-proc-and-call-exp run equal-answer?)
  (test-let-exp run equal-answer?)
  (test-letrec-exp run equal-answer?)
  (test-extended-letrec-exp run equal-answer?)
  )

(test-cps-out-lang run equal-answer?)

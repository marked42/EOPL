#lang eopl

(require racket/lazy-require)
(lazy-require
 ["value.rkt" (equal-answer?)]
 ["../../../base/test.rkt" (test-let-lang)]
 )

(provide (all-defined-out))

(define (test-sum-exp run equal-answer?)
  (equal-answer? (run "+(0)") 0 "sum-exp")
  (equal-answer? (run "+(1, 2, 3)") 6 "sum-exp")
  )

(define (test-print-exp run equal-answwer?)
  (equal-answer? (run "print(1)") 38 "print-exp")
)

(define (test-ref-exp run equal-answwer?)
  (equal-answer? (run "
  let loc1 = newref(33)
    in let loc2 = setref(loc1, 22)
      in deref(loc1)
  ") 22 "explicit references")

  (equal-answer? (run "
  let loc1 = newref(33)
    in setref(loc1, 22)
  ") 23 "explicit references")
)

(define (test-cps-lang run)
  (test-sum-exp run equal-answer?)
  (test-print-exp run equal-answer?)
  (test-ref-exp run equal-answer?)
  (test-let-lang run equal-answer?)
  )

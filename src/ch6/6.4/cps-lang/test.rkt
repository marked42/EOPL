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

(define (test-cps-lang run)
  (test-sum-exp run equal-answer?)
  (test-let-lang run equal-answer?)
  )

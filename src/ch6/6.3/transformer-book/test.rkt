#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../cps-lang/interpreter.rkt" (run)]
 ["../cps-lang/test.rkt" (test-cps-lang test-sum-exp)]
 ["../cps-lang/value.rkt" (equal-answer?)]
 ["transformer.rkt" (cps-of-program)]
 ["test-transformer.rkt" (test-transformer)]
 )

(provide (all-defined-out))

(define (test-list-exp run equal-answer?)
    (equal-answer? (run "list(1, 2, 3)") (list 1 2 3) "list-exp")
    (equal-answer? (run "let x = 4 in list(x, -(x, 1), -(x, 3))") (list 4 3 1) "list-exp")
  )

(test-transformer cps-of-program)
(test-cps-lang (lambda (str) (run str cps-of-program)))
(test-list-exp (lambda (str) (run str cps-of-program)) equal-answer?)

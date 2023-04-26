#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception equal-answer?)]
 ["interpreter.rkt" (run)]
 )

(define (run-test-wrong-number-of-args run)
  (equal-answer? (run "
  let f = proc (x) x
    in try (f 1 2)
       catch (m) 44
  ") 44 "wrong number of args, f accepts only single parameter x, get (1, 2)")
  )

(run-tests run)
(run-test-exception run)
(run-test-wrong-number-of-args run)

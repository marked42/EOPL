#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception equal-answer?)]
 ["interpreter.rkt" (run)]
 )

(define (run-test-division run)
  (equal-answer? (run "try div(4, 2) catch (m) 44") 2 "4 divieded by 2 is 2")
  (equal-answer? (run "try div(4, 0) catch (m) 44") 44 "throws error when divided by 0")
  )

(run-tests run)
(run-test-exception run)
(run-test-division run)

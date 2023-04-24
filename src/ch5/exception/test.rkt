#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception)]
 ["interpreter.rkt" (run)]
 )

(run-tests run)
(run-test-exception run)

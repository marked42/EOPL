#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-call-by-ref)]
 ["interpreter.rkt" (run)]
 )

(run-tests run)
(run-test-call-by-ref run)
